# 背屏 HTML 加载卡顿根因与优化（反编译实证 · 2026-09-15）

> 反编译对象：`subscreencenter.apk` v426082119（RELEASE-1.0.2608211912）
> 关联：`12-WebView加载HTML到背屏.md`（加载机制）/ `18-背屏HTML主题发热卡顿根因与Hook优化.md`（发热省电）
> 本文件专注 **HTML 加载环节** 的卡顿（白屏时间长、资源加载慢、首屏等待久），与发热（运行期）分开

---

## 一、加载卡顿根因总览（一句话）

> **背屏 WebView 的 HTML 资源不是直接从 zip 读，而是先全量解压写盘到 `/data/system/theme_magic/maml_web_temp/`，再逐个按需重复校验读取** —— 大主题（几十个文件/大图/字体/3D 模型）首次加载 = 全量解压写盘 + 每资源请求的 zip 流重开，慢且卡。

### 加载链路（反编译实证）

```
manifest <WebView uri="web/index.html" local="true" useNetwork="all"/>
  ↓ WebViewScreenElement.<init>  [默认 mUseNetwork=2 all]
  ↓ getView() → ensureWebViewCreated() → new MamlWebView(context, local, ua)
  ↓ doTick() 每帧: uriFormatter.getText() ≠ mCurUrl → loadUrl(url)
  ↓ loadUrl(url): isUrlSchemeAllowed && canUseNetwork 校验
  ↓ mHandler.post { lambda$loadUrl$1 }
  │    ├─ local=true → preloadWebAssets(url)   【异步线程池】
  │    │        ├─ ZipResourceLoader: getFileList(web/) 列目录
  │    │        └─ 逐个 preloadAsset(每个文件)
  │    │              └─ createTempFile(loader, maml_web_temp, path)  【write to disk】
  │    └─ 立即 loadUrl("https://local.widget/"+url)   【不等 preload 完成！】
  ↓ MamlWebViewClient.shouldInterceptRequest(host==local.widget)
  │    └─ serveResource(loader, path)
  │          ├─ ZipResourceLoader → createTempFile(...)   【再次 zip 流 + 校验】
  │          │      → FileInputStream → WebResourceResponse(mime, UTF-8, 200, OK, CORS:*, stream)
  │          └─ 其他 loader → getInputStream(path) 直接流
  ↓ 子资源(CSS/JS/图片/字体)每次请求 → 都走 serveResource 的 createTempFile 校验
```

---

## 二、四个卡顿点（逐一实证）

### 卡顿点 ①：首次加载全量解压写盘（大主题最痛）

- `preloadWebAssets(url)` → `lambda$preloadWebAssets$2` → `ZipResourceLoader.getFileList(web/)` 列目录
- 对 **web/ 下每个文件**（含子目录，`preloadDir` 递归）调用 `MamlWebView.preloadAsset(path)`
- `preloadAsset` → `FileUtils.createTempFile(loader, "/data/system/theme_magic/maml_web_temp/", path)`
- `createTempFile` 逻辑（实证）：
  1. `getInputStream(path)` 从 zip **取流**（每次打开 zip 定位）
  2. 文件名 = `temp_` + `(loader.getID()+path+[resourcePath.lastModified])`.hashCode + 扩展名
  3. `File.exists() && length()>0` → 命中缓存直接返回路径（**只跳过写盘，仍取了流+算了 hash**）
  4. 否则 `LL3/b.a(inputStream, file)` 写盘 + `chmod(511)`
- **结论**：大主题 = N 个文件 ×（zip 定位流 + 写盘 + chmod）。3D 模型/大图/字体多时，首屏等很久。

### 卡顿点 ②：preload 与 loadUrl 竞态（黑屏/白屏元凶）

- `lambda$loadUrl$1` 实证：
  ```java
  if (mLocal) preloadWebAssets(url);   // 【异步，不等】
  if (mLocal) url = "https://local.widget/" + url;
  mWebView.loadUrl(url);               // 【立即加载】
  ```
- `preloadWebAssets` 交给 `ExecutorHelper.getLocalTaskExecutor()` 后台线程池执行，**loadUrl 不等它**
- 于是 WebView 马上发子资源请求，`serveResource` 去 `createTempFile` 时**临时文件可能还没写好** → 返回 null → 资源失败/重试（白屏时间拉长）
- **文件数越多、包越大，竞态窗口越大** → 这就是「大主题首屏特别慢/偶发黑屏」的结构性原因

### 卡顿点 ③：每次子资源请求都重开 zip 流 + 校验

- `serveResource` 对 `ZipResourceLoader` 的**每次请求**（HTML/CSS/JS/图片/字体/JSON）都调 `createTempFile`
- `createTempFile` 每次：`getInputStream`（zip 流定位）+ `resourcePath.lastModified()` stat + hash + `File.exists()+length()` stat
- 即使命中缓存，**这一整套 IO 校验仍每次发生**，不是零成本
- HTML 页面加载几十个资源 = 几十次 zip 流重开

### 卡顿点 ④：MIME 猜测每次重复计算

- `serveResource` 每个响应都调 `guessMimeType(path)`（115 指令：MimeTypeMap 查询 + 扩展名分支）
- 虽小，但叠加在每次请求上

---

## 三、加载卡顿 vs 发热(18号) 区分表

| 维度 | 本文件（加载卡顿） | 18号（发热/耗电） |
|---|---|---|
| 阶段 | 首次加载/切换主题/重启后 | AOD/息屏运行期 |
| 表现 | 白屏久、资源慢、偶发黑屏 | 电池温度 40°+、掉电快 |
| 根因 | 全量解压写盘 + 每次请求 zip 流重开 + preload/loadUrl 竞态 | AOD 时 WebView 不 onPause，JS 定时器/CSS 动画/合成器全跑 |
| 优化方向 | 减少文件数/内联、加大线程、避免竞态 | 主题侧停动画 + Hook 补 onPause |

---

## 四、主题侧优化（不 root / 改主题就能做）

### 4.1 文件数压到最少（核心！）

- **所有 JS/CSS 内联进 index.html**（星舰矩阵 v1.8：778KB 单 HTML 就是范例）
- **图片转 base64 内联**（减少 getFileList 条目数）
- **字体用系统字体**（MiSansRoundedSC 等）或只引一个 woff2
- **3D 模型尽量小**（glb 压缩/减面）
- 目标：**web/ 整个目录 ≤ 5 个文件**（同时规避 9.1 的 removeFileForTime 清理误删）

### 4.2 减小包体积

- 大图用 `bufferscale` / CSS 缩放渲染小图
- 音频用短音频/降码率
- 纯 zip 打包（mrc 容器也行），避免 extra 膨胀

### 4.3 首屏体验优化

- HTML 里加 **loading 占位**：背景先显示主题色/文字，资源渐次加载
- JS 用 `defer` / `DOMContentLoaded` 后再初始化重动画
- 大图加 `loading="lazy"`（背屏 WebView 支持）

---

## 五、Hook 优化（电脑 AI 工具开发 · 与 17 号联网 hook 可合成一个模块）

### 5.1 Hook `FileUtils$Companion.createTempFile` —— 消除重复 zip 流重开（中等收益）

- 目标：`com.miui.maml.util.FileUtils$Companion`
- 方法：`createTempFile(Lcom/miui/maml/ResourceLoader;Ljava/lang/String;Ljava/lang/String;)Ljava/lang/String;`
- 优化思路：**内存缓存** temp 路径（key = loader.getID()+path+lastModified），命中直接返回，跳过 `getInputStream`/stat
- 注意：`/data/system/theme_magic/maml_web_temp/` 目录是全局共享的（12号 9.1），缓存 key 必须带 `loader.getID()` 防串主题

```java
// 伪代码：hook createTempFile，命中缓存直接返回
FileUtils.Companion.createTempFile = hook((loader, dir, path) -> {
    String key = loader.getID() + path + new File(loader.getResourcePath()).lastModified();
    if (cache.containsKey(key)) return cache.get(key);   // 跳过 zip 流 + stat
    String p = original(loader, dir, path);
    cache.put(key, p);
    return p;
});
```

### 5.2 Hook `MamlWebView$MamlWebViewClient.shouldInterceptRequest` —— 直接内存流（最大收益）

- 目标：`com.miui.maml.elements.web.MamlWebView$MamlWebViewClient`
- 方法：`shouldInterceptRequest(Landroid/webkit/WebView;Landroid/webkit/WebResourceRequest;)Landroid/webkit/WebResourceResponse;`
- 优化思路：对 `local.widget` 请求，**直接从 ResourceLoader 读流返回**（跳过 createTempFile 写盘/校验），类似非 Zip 分支的 `getInputStream` 路径；或先查已解压 temp 文件存在则 `FileInputStream`（省 zip 重开）
- 效果：每次子资源请求省掉 zip 流定位 + stat —— 大主题加载肉眼可见变快

### 5.3 Hook 竞态：`preloadWebAssets` 后置 loadUrl（治黑屏）

- 目标：`WebViewScreenElement`
- 思路：hook `lambda$loadUrl$1` 或 `loadUrl`，让 **preload 完成后**再 `loadUrl`（或在 `preloadWebAssets` 返回的 runnable 上加个 await）
- 难度中；收益：消掉黑屏/白屏竞态

### 5.4 合成建议：RearScreenBoost 模块（与 18 号 AOD onPause + 17 号联网合并）

```
行为域: com.xiaomi.subscreencenter + com.android.thememanager + com.miui.miwallpaper
功能一: AOD 时 WebView.onPause()/onResume()（18号第四章）   → 省电
功能二: canUseNetwork + isUrlSchemeAllowed 放行（17号10.2） → 联网
功能三: createTempFile 内存缓存 + shouldInterceptRequest 直读流（本文件5.1/5.2） → 加载提速
```

---

## 六、验证清单

- [ ] 主题 web/ 目录文件数 ≤ 5（`getFileList` 无压力）
- [ ] 首次加载时间（冷启动）：优化前记录 vs 优化后对比（logcat `Preload completed: N files`）
- [ ] 重启后无黑屏（9.1 场景）
- [ ] Hook 后 logcat 不再每秒刷 `shouldInterceptRequest: uri=` 大量 zip 流日志

---
*作者：唯梦倾城 | 2026-09-15 | 与 18号发热 顿优化形成姊妹篇*