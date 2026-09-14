# 17-背屏联网 Xposed Hook 模块实现方案（2026-09-14 深挖实证）

> 目标：让背屏中心 `com.xiaomi.subscreencenter` 的 WebView HTML 主题获得**联网能力**
> 前置：LSPosed 框架已装（zygisk_lsposed，org.lsposed.manager 2.0.1），Root 可用（KSU）
> 参考：`com.codex.rearscreenfix`（Rear Screen Bypass v0.1.3，已装，但只改主题路径不碰网络）

---

## 一、为什么背屏 WebView 无法联网（反编译+系统实证）

### 1.1 权限链完整实证

| 环节 | 证据 | 结论 |
|---|---|---|
| INTERNET 权限定义 | `Permission [android.permission.INTERNET] sourcePackage=android uid=1000 gids=[3003] prot=normal` | **INTERNET 映射 gid 3003 = AID_INET** |
| 背屏 manifest | `dumpsys package` 的 requested permissions **无 INTERNET**（只有 `miui.permission.EXTRA_NETWORK` 等） | **未声明 INTERNET → 不获 inet 组** |
| 背屏进程 Groups | `/proc/<pid>/status` → `Groups: 3007 9997 20209 50209 99909997` **无 3003** | **进程不在 inet 组** |
| 实际联网 | `su u0_a209 -c curl https://httpbin.org` → `000`（连接失败） | **socket 创建被内核拒绝** |
| EXTRA_NETWORK 权限 | `Permission [miui.permission.EXTRA_NETWORK] uid=1000 gids=[] prot=signature\|privileged` | **gids=[] 不映射任何组，帮不上忙** |

**结论**：背屏 app 因 manifest 未声明 `android.permission.INTERNET`，进程未获得 gid 3003（AID_INET），**所有 socket 网络请求被内核强制拒绝**。这跟 CORS、端点、WebView 配置**无关**。

### 1.2 重装改造版为什么黑屏（已踩坑）

- 原版背屏：**系统签名**（`6c02dd51`，V3），flags=`SYSTEM UPDATED_SYSTEM_APP`
- MT 重签版：**测试签名**（`a40da80a`），签名不一致
- 重装后：系统应用身份丢失 + 数据清空 + signature 级权限（EXTRA_NETWORK 等）全掉 → 背屏初始化异常黑屏
- **教训：系统应用（SYSTEM flag）不能随便换签名重装，必须用原系统 key 或走 hook**

---

## 二、Hook 方案选型

### 2.1 关键认知：Xposed 应用内 hook 无法绕过内核 gid 检查

socket 网络权限是**内核 + netd** 在创建 socket 时按进程 gid 强制检查的。**hook 应用进程内的 Java 层（如 `WebViewClient`、`isUrlSchemeAllowed`）无法让没有 inet 组的进程联网**。

### 2.2 可行方案（按推荐度排序）

| 方案 | 原理 | 难度 | 风险 | 推荐 |
|---|---|---|---|---|
| **A. Hook zygote fork 补 gid** | LSPosed hook `Zygote.forkAndSpecialize`/`ZygoteInit`，在 fork 背屏 uid 时把 3003 补进 gids | 高 | 中（影响系统 zygote） | ⭐⭐⭐ 根治 |
| **B. Root 脚本 + setns 代理** | 用 root 起一个带 inet 组的代理进程，背屏 WebView 走代理 | 中 | 低 | ⭐⭐ 稳定 |
| **C. 修改系统 packages.xml 补权限** | root 直接改 `/data/system/packages.xml` 给背屏加 `INTERNET` 权限 + 重启 | 低 | 中（需重启） | ⭐⭐ 简单 |
| **D. hook WebView 走 root 转发** | hook `MamlWebView`/`WebViewClient`，把请求转发给 root 服务（如 MiRoot） | 高 | 低 | 复杂 |

---

## 三、方案 A：Hook Zygote fork 补 gid 3003（推荐）

### 3.1 原理

LSPosed 能 hook 系统进程（zygote/system_server）。在 `Zygote.forkAndSpecialize`（Android 12+ 用 `Zygote.forkAndSpecialize`，实际底层 `nativeForkAndSpecialize`）中，**在 fork 返回前**拦截 uid/gids 参数，当 uid == 10209（背屏）时向 gids 数组追加 3003。

```java
// ZygoteHook.java
public class ZygoteHook implements IXposedHookLoadPackage {
    public static final String PKG = "com.xiaomi.subscreencenter";
    public static final int UID = 10209; // dumpsys 确认
    public static final int AID_INET = 3003;

    @Override
    public void handleLoadPackage(XC_LoadPackage.LoadPackageParam lpparam) {
        if (!lpparam.packageName.equals("android")) return; // 只 hook zygote/system_server

        XposedHelpers.findAndHookMethod(
            "com.android.internal.os.Zygote", lpparam.classLoader,
            "forkAndSpecialize",
            int.class, int.class, int[].class, int.class,
            int[][].class, int.class, String[].class,
            String.class, String.class, int[].class, boolean.class,
            String[].class, String.class, String.class, boolean.class,
            boolean.class, String.class, String[].class,
            new XC_MethodHook() {
                @Override
                protected void beforeHookedMethod(MethodHookParam param) {
                    int uid = (int) param.args[0];
                    if (uid == UID) {
                        int[] gids = (int[]) param.args[2];
                        int[] newGids = Arrays.copyOf(gids, gids.length + 1);
                        newGids[gids.length] = AID_INET;
                        param.args[2] = newGids;
                        XposedBridge.log("ZygoteHook: 背屏 uid " + uid + " 已补 inet gid 3003");
                    }
                }
            });
    }
}
```

**注意**：
- `forkAndSpecialize` 签名随 Android 版本变化（Android 13/14/15 参数不同），用 `XposedHelpers.findAndHookMethod` 前先 `getDeclaredMethods` 探测签名，或直接 hook `nativeForkAndSpecialize`（`com.android.internal.os.Zygote.nativeForkAndSpecialize`）。
- LSPosed 作用域选 **system（zygote）**。
- **风险**：hook zygote 影响所有 app 的 fork，逻辑必须只对 uid==10209 生效。

### 3.2 备选：hook Application 后反射改 gids（不可行，说明）

进程启动后 gid 已固定，`setgroups()` 需要 CAP_SETGID 且 App 无此能力——**应用进程内无法补组**，必须 zygote 层。

---

## 四、方案 B：Root 代理转发（稳定、无需 hook 系统）

### 4.1 原理

MiRoot（`com.wmqc.miroot`）有 root 通道，能联网。在背屏 app 里 hook `MamlWebView` 的 `shouldInterceptRequest`，把 `http/https` 请求**转发给 MiRoot 的 root 代理服务**（本地 HTTP 服务），MiRoot 用 root 权限联网后返回结果。

```java
// 背屏内 hook：把网络请求转发给本地 root 代理
XposedHelpers.findAndHookMethod(
    "com.miui.maml.elements.web.MamlWebView$MamlWebViewClient",
    lpparam.classLoader,
    "shouldInterceptRequest",
    WebView.class, WebResourceRequest.class,
    new XC_MethodHook() {
        @Override
        protected Object afterHookedMethod(MethodHookParam param) {
            WebResourceResponse orig = (WebResourceResponse) param.getResult();
            if (orig != null) return orig;
            WebResourceRequest req = (WebResourceRequest) param.args[1];
            String url = req.getUrl().toString();
            if (url.startsWith("https://") || url.startsWith("http://")) {
                // 转发到 root 代理 http://127.0.0.1:PORT/fetch?url=...
                // MiRoot 用 OkHttp/HttpURLConnection(有 root+inet) 请求后返回
                return proxyFetch(url);
            }
            return orig;
        }
    });
```

**优点**：不碰 zygote，只 hook 背屏进程内，风险低。
**缺点**：需要 MiRoot 侧提供 root 代理 HTTP 服务（需开发）。

---

## 五、方案 C：修改 packages.xml 补权限（最简单，需重启）

### 5.1 原理

`/data/system/packages.xml` 记录了每个 app 的权限授予。用 root 直接改：给 `com.xiaomi.subscreencenter` 加 `<uses-permission name="android.permission.INTERNET"/>`，重启后 PackageManager 会补发 inet 组。

### 5.2 步骤

```bash
# 1. 备份
cp /data/system/packages.xml /data/system/packages.xml.bak
# 2. 在 <package name="com.xiaomi.subscreencenter"> 的 <perms> 段插入
#    <item name="android.permission.INTERNET" granted="true" flags="0" />
# 3. 重启
reboot
# 4. 验证
ps -A -o USER 2>/dev/null | grep subscreen  # 或用 /proc/<pid>/status 看 Groups 是否含 3003
```

**注意**：
- 需 root + SELinux 放行（核心破解/Enforcing 下 root 可写，实测 Enforcing 下 root 可写 /data/system）
- 改错 packages.xml 可能导致系统起不来，务必先备份
- 重启后背屏 app 首次启动应自动获得 inet 组

---

## 六、Hook 参考：com.codex.rearscreenfix 结构（已装模块）

### 6.1 模块信息

- 包名：`com.codex.rearscreenfix`（Rear Screen Bypass v0.1.3，versionCode 5）
- 作用域：`com.xiaomi.subscreencenter` + `com.android.thememanager`
- 核心类：`com.codex.rearscreenfix.RearScreenBypass`（69 方法，IXposedHookLoadPackage）

### 6.2 它 hook 了什么（只改主题路径，不碰网络）

| Hook 目标类 | 方法 | 作用 |
|---|---|---|
| `com.rearScreen.bean.RearScreenListItemBean` | 构造/字段 | 修复主题列表项路径 |
| `com.rearScreen.manager.RearScreenCenterManager` | 相关方法 | 主题管理路径修复 |
| `com.rearScreen.maml.MAMLCacheHelper` | 相关方法 | MAML 缓存路径修复 |
| `com.rearScreen.manager.RearScreenResOperationHelper$Companion` | 相关方法 | 资源操作路径修复 |
| `com.rearScreen.bean.RearScreenListItemBean.getRuntimeDirWithAuthWhite` | 相关方法 | 白名单运行时路径 |

**作用**：解决第三方主题（AI 壁纸替换官方主题）在主题管理器/背屏中心里的**文件路径、缓存路径、应用流程**问题。**不涉及网络**。

### 6.3 借鉴点

- 用 `hookSafe` 包装每个 hook（try-catch，失败不影响其他）——**强烈建议沿用**
- 用反射安全工具（safeCallMethod/safeStringField/safeObjectField）避免崩溃
- 类名可能混淆（`m2.a`、`Z1.g`、`B0.d` 等 lambda 里的目标），hook 时用 `findClass` + 字符串匹配

---

## 七、推荐实现步骤（方案 C 优先，零开发）

```bash
# ① 先试方案 C（最简单，零开发）
cp /data/system/packages.xml /data/system/packages.xml.bak
# 编辑 packages.xml 给背屏加 INTERNET 权限
reboot
# 验证背屏 Groups 有 3003

# ② 若 C 不行，方案 A（zygote hook，根治）
# 写 ZygoteHook 模块 → LSPosed 作用域选 system → 重启

# ③ 方案 B 作为兜底（不动系统）
# MiRoot 提供 root 代理 + 背屏 hook 转发
```

---

## 八、验证清单

- [ ] 背屏进程 `/proc/<pid>/status` Groups 含 **3003**
- [ ] `su u0_a209 -c curl https://httpbin.org/anything` 返回 **200**
- [ ] 背屏 XP 主题 IE 窗口显示 **✅ 联网成功 + 公网 IP**
- [ ] WebView 内 fetch https API 正常

---

## 九、附：关键类/方法速查（subscreen.apk v426082119）

- `WebViewScreenElement.isUrlSchemeAllowed(String)` → scheme 白名单（local=true 挡 http/https，local=false 只放 https）
- `WebViewScreenElement.canUseNetwork()` → useNetwork 判断（"all"=2 恒 true）
- `WebViewScreenElement.loadUrl(String)` → 联网入口（先白名单后 useNetwork）
- `MamlWebView.<init>(Context, boolean local, String userAgent)` → WebView 构造（JS 开、缩放禁、DOM storage=local）
- `MamlWebView$MamlWebViewClient.shouldInterceptRequest` → local.widget 资源拦截（CORS 全开）
- `MamlInterface` → JS 桥（getDoubleByName/getStringByName/putInt/putString/doAction 等全存在）
- `SubScreenCenterApp` → 背屏 Application 入口（可 hook onCreate 注入）

---
*作者：唯梦倾城 | 2026-09-14 | 与 12-WebView加载HTML到背屏.md 第九章配套*
