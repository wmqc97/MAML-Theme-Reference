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

## 十、反编译实证：HTML 加载体系与联网增强 Hook 坐标（2026-09-15 更新，供电脑 AI 工具直接开发）

> 本节基于 subscreencenter.apk v426082119（RELEASE-1.0.2608211912，minSdk 35 / targetSdk 37）MT 反编译实证，所有类名/方法/Smali 行为均来自实测，**电脑端 hook 模块可直接照抄类名开发**。

### 10.1 HTML 加载完整类体系（都在背屏 app 内，无混淆）

| 类 | 职责 | 关键点 |
|---|---|---|
| `com.miui.maml.elements.WebViewScreenElement` | MAML `<WebView>` 元素（TAG_NAME="WebView"） | 联网三重限制都在这里：`isUrlSchemeAllowed` / `canUseNetwork` / `loadUrl` |
| `com.miui.maml.elements.web.MamlWebView` | 实际 WebView（继承 `android.webkit.WebView`） | 构造器配置全部 WebSettings；`VIRTUAL_BASE_URL="https://local.widget/"`，`VIRTUAL_HOST="local.widget"` |
| `com.miui.maml.elements.web.MamlWebView$MamlWebViewClient` | WebViewClient | `shouldInterceptRequest`（local.widget 资源拦截）、`shouldOverrideUrlLoading`（白名单） |
| `com.miui.maml.elements.web.MamlWebView$MamlWebChromeClient` | WebChromeClient | 进度回调等 |
| `com.miui.maml.elements.web.MamlInterface` | JS 桥，注入名 `maml` | 16 个方法全会话实证，见 10.4 |
| `com.miui.maml.commands.WebViewCommand` | MAML 命令 `runjs`/`reload`/`goback` | 命令参数 & 需 `&amp;` |
| `com.miui.maml.ScreenElementRoot` | 根元素 | `mMamlViewConfig` / `setMamlViewOnExternCommandListener` |
| `com.miui.maml.component.MamlView` | MAML 容器 View | 背屏主视图容器 |

**关键常量（MamlWebView）**：`VIRTUAL_BASE_URL = "https://local.widget/"`，`VIRTUAL_HOST = "local.widget"`——HTML 本地资源全部以 `https://local.widget/<资源路径>` 形式加载，由 `shouldInterceptRequest` 兜底接管。

### 10.2 联网三重限制（实证 Smali 行为）

#### ① `WebViewScreenElement.isUrlSchemeAllowed(String)` — scheme 白名单
- 逻辑：空串 false；含 `://` 的检查前缀，**含 `javascript:` / `data:` / `vbscript:` → false（禁）**；`https://` 前缀 → true；其余（含 `http://`）→ false
- **local=true 时连 http 都禁**，local=false 只放 https。
- **Hook 建议**：`XposedHelpers.findAndHookMethod("com.miui.maml.elements.WebViewScreenElement", lpparam.classLoader, "isUrlSchemeAllowed", String.class, new XC_MethodHook() { @Override protected void beforeHookedMethod(MethodHookParam param) { param.setResult(true); } })` — 让所有 scheme 放行

#### ② `WebViewScreenElement.canUseNetwork()` — useNetwork 判断
- Smali 实证：`mUseNetwork == 2 (USE_NETWORK_ALL) → return true`（恒真）；`== 1 (USE_NETWORK_WIFI) → 仅非计费且已连接时 true`；否则 false
- **Hook 建议**：同样 before 返回 true，一劳永逸。

#### ③ `WebViewScreenElement.loadUrl(String)` — 联网入口（先白名单后 useNetwork）
- Smali 实证顺序：① `isUrlSchemeAllowed(url)` 不过 → 打日志 `loadUrl blocked by scheme whitelist` 直接 return；② `canUseNetwork()` false 且 url 以 `http` 开头 → 打日志 `loadUrl canceled due to useNetwork setting.` return；③ 通过 → 存 `mCurUrl` 并 `mHandler.post` 到主线程执行
- **Hook 建议**：只 hook ①② 两个返回点即可，无需动 loadUrl 本身。

### 10.3 MamlWebView 构造器 WebSettings 全配置（实证）

`MamlWebView.<init>(Context, boolean local, String userAgent)`：
- `setUserAgentString(userAgent)`（非空时）
- `setAllowFileAccess(false)` / `setAllowContentAccess(false)`（**禁文件/内容访问**）
- `setJavaScriptEnabled(true)`（JS 开）
- `setBuiltInZoomControls(false)` / `setDisplayZoomControls(false)` / `setSupportZoom(false)`
- `setSupportMultipleWindows(false)`
- `setDomStorageEnabled(local)`（local=true 才开 DOM storage）
- `setMediaPlaybackRequiresUserGesture(!local)`
- `setInitialScale(100)` / 滚动条禁用 / 长按禁用 / `setLayerType(LAYER_TYPE_HARDWARE=2, null)`
- 设置 `MamlWebViewClient` + `MamlWebChromeClient`

**注意**：此处**没有** `setBlockNetworkLoads(true)`——WebSettings 层并未禁止网络，真正的限制在 10.2 的三个方法 + Manifest 缺 INTERNET 权限。

### 10.4 MamlInterface JS 桥方法全表（16 个，实证）

`maml.getDoubleByName(name)` / `maml.getDoubleByIndex(i)` / `maml.getStringByName(name)` / `maml.getStringByIndex(i)` / `maml.getObjByName(name)` / `maml.getObjByIndex(i)` / `maml.putInt(name, i)` / `maml.putDouble(name, d)` / `maml.putString(name, s)` / `maml.putObj(name, obj)` / `maml.registerVariable(name)` / `maml.registerDoubleVariable(name)` / `maml.doAction(name)` —— 全部真实存在（对应 `Variables.get/put/register + ScreenElement.performAction`）。

### 10.5 Manifest 权限实锤（联网失败内核根因）

subscreencenter manifest **无 `android.permission.INTERNET`**！已声明权限含：`ACCESS_WIFI_STATE` / `WAKE_LOCK` / `DEVICE_POWER` / `WRITE_SECURE_SETTINGS` / `miui.permission.EXTRA_NETWORK` 等，**独缺 INTERNET** → 进程 Groups 无 gid 3003 → socket 被内核拒绝（curl 000）。

### 10.6 电脑 AI 工具开发 recommandation（三条路）

**方案 A（zygote hook 根治，推荐）**：hook `Zygote#forkAndSpecialize` / `Zygote#forkAndSpecializeInternal`，给目标 uid（背屏 10209）追加 gid 3003，进程自带 inet 组，WebView 直接联网。电脑侧可直接写 Xposed/LSPosed 模块。

**方案 B（进程内 hook 增强）**：hook 上述三个方法（10.2 ①② 强制放行）——但这只能过 MAML 层限制，**过不了内核 gid 3003**，必须配合 A 或 C。

**方案 C（packages.xml 加权限，零开发）**：给背屏加 `<uses-permission name="android.permission.INTERNET"/>` + 重启（需 root + 备份）。

**推荐组合**：A（或 C）+ B，缺一不可。B 的 hook 代码（LSPosed 模块可直接用）：

```java
// 作用域: com.xiaomi.subscreencenter + com.android.thememanager
XposedHelpers.findAndHookMethod("com.miui.maml.elements.WebViewScreenElement", cl, "canUseNetwork", new XC_MethodHook() {
    @Override protected void beforeHookedMethod(MethodHookParam p) { p.setResult(true); }
});
XposedHelpers.findAndHookMethod("com.miui.maml.elements.WebViewScreenElement", cl, "isUrlSchemeAllowed", String.class, new XC_MethodHook() {
    @Override protected void beforeHookedMethod(MethodHookParam p) { p.setResult(true); }
});
```

---
*作者：唯梦倾城 | 2026-09-15 更新（追加第十章反编译实证） | 与 12-WebView加载HTML到背屏.md 第九章配套*
