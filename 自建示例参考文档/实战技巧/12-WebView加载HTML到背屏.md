# WebView 加载 HTML 到背屏主题

> 🆕 2026-09-11 实测：背屏 WebView 可完整运行 Three.js r160（UMD 整库内嵌 + base64 纹理，单文件 761KB~5.4MB，宇宙漫游验证）；开源项目移植要点见 13 号第九章，多分辨率分档用 uriExp 切换。
> 验证日期：2026-09-09 ~ 09-10
> 状态：✅ 已验证可行（星际航海 / 涨水充电 / 网络测试多个主题实测）

## 核心写法

manifest.xml 中使用 `<WebView>` 元素，本地 HTML 放在主题包内的 `web/` 目录：

```xml
<Widget version="2" frameRate="30" scaleByDensity="false" screenWidth="976" transparentSurface="true">
  <WebView
      name="orbit_webview"
      x="0"
      y="0"
      w="#view_width"
      h="#view_height"
      local="true"
      cachePage="true"
      uri="web/index.html" />
</Widget>
```

## 关键点

| 要点 | 说明 |
|------|------|
| 元素名 | `<WebView>`（注意大小写，不是 `<web>`） |
| local="true" | 加载主题包内本地文件（必须，去掉后直载在线 URL 打不开） |
| uri | 相对路径，相对主题包根目录，如 `web/index.html` |
| transparentSurface="true" | 根标签添加，透明背景 |
| 尺寸 | 用 `#view_width` / `#view_height` 自适应背屏 |
| frameRate | 30 足够（HTML 自己跑动画，MAML 不重绘） |

## 目录结构

```
星际航海/
├── manifest.xml      ← WebView 声明
├── var_config.xml    ← 可选配置
└── web/              ← HTML 项目（完整放入）
    ├── index.html
    ├── assets/  data.json  *.ogg  *.png   ← 本地资源直接放 web/ 下
    └── src/
```

## 注意事项

1. **整个 HTML 项目直接放入 `web/` 子目录**，入口必须是 `web/index.html`（或 uri 指定的相对路径）
2. HTML 内相对引用（`assets/...`、`src/...`、`data.json`、本地图片/音频）都基于 `web/` 目录解析，**本地资源全部可加载**
3. 打包时用 `miroot_theme_pack` 把整个目录打成 zip/mrc
4. 替换到 AI 壁纸目录的 `rearscreen` 时，必须是**zip 包文件**（不是目录），系统按 zip 解压加载
5. Three.js/WebGL 在背屏 WebView 可正常跑，已验证
6. 背屏物理分辨率 976×596，但 **CSS 视口宽度不是 976**（实测约 360px），布局别用固定 976px 设计，详见下方避让/适配节
7. **左侧 277px 摄像头区**：背景可全屏，内容必须避让（见下方专节）

## HTML 页面规范（全屏适配 · 禁止缩放）

背屏 WebView 中 HTML **不能缩放、不能超出屏幕**，所有页面必须全屏适配：

### 1. viewport 禁止缩放（必加）

```html
<meta name="viewport" content="width=976, initial-scale=1, maximum-scale=1, user-scalable=no, viewport-fit=cover">
```

- `maximum-scale=1` + `user-scalable=no`：禁止用户双指缩放
- `width=976`：声明逻辑宽度（注：实际 CSS 视口可能仍非 976，见下方）

### 2. 全屏适配（必加 CSS）

```css
html,body{width:100%;min-height:100%;overflow-x:hidden;overflow-y:auto;margin:0}
```

- `overflow-x:hidden`：**禁止横向滑动/滚动**（内容不许超出视口宽度）
- `overflow-y:auto`：**允许纵向滚动**（内容多时上下滑动查看）
- 背景层/画布用 `position:fixed;inset:0` 铺满全屏
- 内容容器用流式 block 布局（**不要用 flex 撑高度**，flex 在背屏 WebView 高度塌陷会导致只显示第一行）

## 背屏摄像头避让（内容避让规则）

**背屏物理 976×596 横向，左侧 277px 是摄像头区域。**

### ⚠️ 必须用 vw 比例，不要用固定 px！

**背屏 WebView 的 CSS 视口实测 348×212，dpr 2.8125（= 物理 976×596 ÷ dpr，不是 976）**。固定 `left:300px` 会把内容挤出屏幕（只剩 50-60px 可见 + 横向滚动）。

正确写法：**277px ÷ 976px ≈ 28.4%，用 29vw**（含留白），任何视口下都精确避开物理摄像头：

```css
html,body{overflow-x:hidden}
body{padding-left:29vw}      /* 内容整体右移避开摄像头 */
```

- 背景底图（水体/星空/渐变等）可**全屏铺满**（用 fixed;inset:0），摄像头区域显示背景不影响观感
- **所有可读内容（电量数字/文字/图标/按钮）必须避让左侧 277px**，用 `body{padding-left:29vw}` 或容器 `margin-left:29vw`

## 能力边界实测（2026-09-10 小米 17 Pro Max 背屏）

> 通过 9 轮主题实测得出，做 HTML 背屏主题以此为准

### ✅ 可用

| 能力 | 说明 |
|------|------|
| **iframe 加载在线网页** | 唯一放行的网络通道！`<iframe src="https://...">` 可加载在线网页 |
| **navigator.getBattery()** | ⭐ 拿到**真实电量**（如「电量 78% 充电中」），充电动画可接真实数据 |
| **battery 事件监听** | levelchange / chargingchange 触发（充电/断电实时感知） |
| **传感器 devicemotion** | 加速度/陀螺仪数据可读 |
| **deviceorientation** | 方向欧拉角（α/β/γ）可读 |
| **触摸事件 touchstart** | 背屏支持触摸交互（点击/手势控制 UI） |
| **localStorage / sessionStorage** | 数据持久化读写 OK |
| **IndexedDB** | 大型数据存储可用 |
| **fetch 本地 data.json** | 主题包内 JSON 可读取（`fetch('data.json')`） |
| **iframe + postMessage** | 本地页面间双向通信（模块化数据通道） |
| **dialog.showModal** | 原生弹窗可用（模态 + backdrop） |
| **AudioContext** | Web Audio 合成音效（播放需手势 resume） |
| **本地图片/音频** | web/ 内 .png/.ogg 可加载；音频播放需**用户手势**（自动播放被拦） |
| **Canvas 2D / WebGL** | 2D 渐变文字、3D 渲染（Three.js）全 OK |
| **CSS 动画 / JS 定时器** | requestAnimationFrame/setInterval 正常 |

### ❌ 不可用

| 能力 | 现象 |
|------|------|
| fetch/XHR **在线** API | CORS 拦截（file:// 页面 Origin=null，报 Failed to fetch） |
| JSONP（script 跨域） | script 标签加载在线脚本被禁 |
| img 在线图片 | 多个图源全失败（子资源网络请求被拦，仅 iframe 导航放行） |
| 在线 CSS（link） | 加载失败 |
| 在线音频/视频 | 加载失败 |
| navigator.vibrate | 不支持/被拒 |
| WebSocket 在线连接 | 连接失败（在线网络全禁，仅 iframe 放行） |
| uri 直载在线 URL | 「网页无法打开」（local=true 限定本地，去掉 local 也不行） |
| MAML 变量传参 uri | uri 带 `#battery_level` 变量不替换（HTML 收不到） |

### ⚠️ 待验证

| 能力 | 说明 |
|------|------|
| visibilitychange | 锁屏/切页才触发，测试窗口内未触发（不判定失败） |

### 结论

- **联网**：只能靠 iframe 内嵌在线网页，JS 拿不到在线接口数据（fetch/JSONP/WebSocket 全禁）
- **真实电量**：用 `navigator.getBattery()` + battery 事件监听（不是 MAML 传参）
- **交互**：触摸可用，可做点击/滑动控制
- **资源**：本地全通，在线子资源全禁
- **模块化**：iframe + postMessage 可做页面间通信

## 交互与滑动经验

1. **纵向滚动**：`html,body{overflow-y:auto}` 有效，内容多时上下滑动
2. **横向禁止**：`overflow-x:hidden`，内容宽度用 vw 控制，绝不超视口
3. **流式布局优先**：多行列表用 block 流式（`display:block` + margin），**不要 flex 撑高**（flex 高度塌陷 → 只显示第一行）
4. **音频播放**：必须用户手势触发（点击后 `audio.play()` / AudioContext resume），自动播放被拦
5. **触摸测试**：`addEventListener('touchstart')` 可收到坐标，可做全屏点击层
6. **文字绘制**：CSS 渐变文字（background-clip:text）不渲染会全透明，用 canvas fillText

## 为什么不用其他方式

- ❌ `<web>`（小写）— 无效，官方没有此元素
- ❌ IntentCommand 打开 file:// — 会跳出背屏到浏览器，不是内嵌
- ❌ 纯 MAML 重绘 — 无法承载 Three.js/复杂 JS
- ✅ `<WebView>` — 内嵌 WebView，HTML/JS/WebGL 完整运行

## 系统状态实测（v10，2026-09-10）

背屏实测精确数据（用户验证）：

| 探测项 | 结果 |
|--------|------|
| getBattery | ✅ 电量/充电状态可读（如「63% 充电:true」） |
| navigator | platform:Linux armv8l · zh-CN · 8GB · 8核 · javaEnabled:false |
| **screen** | **348×212 · landscape-primary · dpr 2.8125**（开发按此缩放适配！） |
| connection | 4g · 10Mbps（仅信息） |
| window 注入桥 | ❌ 未见注入（无 Android/MiuiWebView JS 桥） |
| visibilityState | ✅ visible 可读（锁屏/切页捕获状态，可暂停渲染省电） |
| 音量 | 只能控制网页内 audio.volume / AudioContext，系统音量无 API |
| MediaSession | ❌ 无（不能接管系统播放器/拿歌曲元数据） |
| window 层级 | top===self（独立顶层窗口） |

### 关键结论（做背屏 Web 项目以此为准）

1. **电池 API 可用**：JS 直接读背屏电量/充电状态 → 充电动画接真实数据
2. **AudioContext 正常**：网页内可播音效/背景乐；但不能读/改系统音量，只能控制页面内音量
3. **visibilityState 正常**：熄屏/锁屏可捕获 → 用来暂停 3D 渲染降功耗
4. **屏幕尺寸是 348×212（dpr 2.8125）不是 976×596**：网页按此做缩放适配，否则画面会缩小/错位；避让仍用 29vw（=物理 277px）
5. **无 JS 桥**：网页 ↔ MAML 双向通信需自己搭（iframe+postMessage 是页面内方案）
6. **无 MediaSession**：拿不到正在播放音乐标题等系统媒体信息
7. **top===self**：独立顶层窗口

> ⚠️ 注意：CSS 视口高度只有 212px！内容多必须 `overflow-y:auto` 滚动；大元素（如 158px 数字 + 92px 电池框）会超高，需按 348×212 重新排版。

## 补充实测（v11/v12，2026-09-10）

### 锁屏感知（省电关键）

| 信号 | 锁屏时 | 切页时 |
|------|--------|--------|
| visibilityState / visibilitychange | ❌ 不触发（背屏独立窗口，主屏锁屏 WebView 仍 visible 全速运行） | ✅ 触发（切到其他页面/应用 → hidden） |
| window blur/focus | ❌ 不变 | 待确认 |
| AudioContext.state | ❌ 保持 running | 待确认 |
| interval/rAF 节流检测 | ❌ 无延迟（全速） | 待确认 |

- **省电方案**：用 `visibilitychange→hidden` 在**切页/切应用**时暂停渲染；**锁屏无法感知**（背屏常显特性），交给系统管
- 背屏 WebView 锁屏时依然全速运行，别指望锁屏自动降载

### 剪贴板

| 方式 | 结果 |
|------|------|
| `document.execCommand('copy')` | ✅ **手势下可写剪贴板**（实测成功复制「v12-execCommand-复制内容」） |
| `navigator.clipboard.readText/writeText` | ❌ file:// 非 secure context，API 不存在或拒绝 |
| 读剪贴板 | ❌ 无可靠途径（execCommand 只能写不能读） |

- 结论：可做「点击复制」类交互；不能读剪贴板内容

**v13 读取确认（2026-09-10）**：剪贴板读取全部失败——`navigator.clipboard.readText`（自动/手势）拒绝、`execCommand("paste")` 禁用、输入框 paste 事件/系统粘贴菜单不触发。
**最终结论：剪贴板只能手势写（execCommand copy），完全不能读。**

### 硬件调用（v14/v15，2026-09-10）

| 硬件 | 结果 |
|------|------|
| mediaDevices / enumerateDevices | ⚠️ 存在但设备列表需授权（file:// 非 secure context） |
| getUserMedia 摄像头/麦克风 | ❌ 拒绝（file:// 非安全上下文 + 权限） |
| geolocation 定位 | ❌ 拒绝 |
| Generic Sensor（光线/陀螺仪/加速度计等） | ❌ 无 API 或创建失败（devicemotion/deviceorientation 事件可用但不给传感器对象） |
| getGamepads / 蓝牙 / NFC / USB | ❌ 无 |
| **navigator.vibrate 震动** | ❌ **实测完全无效**（API 返回 true 但物理无震动，背屏 WebView 无震动权限） |

**结论：背屏 WebView 不能调用摄像头/麦克风/定位/物理传感器对象/震动等硬件；只有 devicemotion/deviceorientation 事件数据可用（v8 已验证）。**

## WebView 元素参数完整清单（反编译确认 2026-09-10）

来源：主题管理器 classes2.dex `com.miui.maml.elements.WebViewScreenElement` / `WebViewCommand` 反编译

### manifest.xml `<WebView>` 元素参数

| 参数 | 类型 | 说明 | 实测状态 |
|------|------|------|----------|
| `name` | string | WebView 实例名（供命令 target 引用） | ✅ 用 |
| `x/y/w/h` | int | 位置尺寸，支持 #view_width 等 | ✅ 用 |
| `uri` | string | 直接 URL（本地相对路径或在线） | ✅ 本地可用；在线直载 ❌ 打不开 |
| `uriExp` | string 表达式 | **uri 表达式**（可拼 MAML 变量） | ⚠️ 反编译存在；直接写 `web/index.html?b=#battery_level` 实测黑屏（需正确表达式语法，未验证成功） |
| `local` | bool | 本地加载模式（必须 true 加载 web/） | ✅ 必须 |
| `cachePage` | bool | 页面缓存 | ✅ 用 |
| `useNetwork` | string | 联网控制：`all`（所有网络）/`wifi`（仅 WiFi） | ⚠️ 反编译确认，未实测 |
| `userAgent` | string | 自定义 UA | ⚠️ 反编译确认，未实测 |

### `<WebViewCommand>` 命令（MAML 控制 WebView）

```xml
<ExternalCommands>
  <Trigger action="init">
    <WebViewCommand target="wv" command="RUNJS" params="...JS代码..." delay="3000"/>
    <WebViewCommand target="wv" command="RELOAD"/>
    <WebViewCommand target="wv" command="GOBACK"/>
  </Trigger>
</ExternalCommands>
```

| 命令 | 作用 | 实测状态 |
|------|------|----------|
| `RUNJS` + params | 执行 HTML 内 JS（evaluateJavascript） | ⚠️ 反编译确认（evaluateJavascript 调用）；实测 init+delay 3s 未生效，疑因 WebView 未就绪或 params 需表达式语法，待排查 |
| `RELOAD` | 重新加载页面 | ⚠️ 未实测 |
| `GOBACK` | 返回上一页 | ⚠️ 未实测 |

### WebView 加载机制（反编译发现）

1. **web/ 资源解压**：主题包 web/ 目录被复制到 `/data/system/theme_magic/maml_web_temp/` 后加载（首次解压可能慢）
2. **本地域名**：本地资源通过 `https://local.widget/` 提供（HTML 相对引用基于此）
3. **MIME 拦截器**（WebViewAssetLoader 类似）：支持 `.html/.htm/.css/.js/.mjs/.json/.wasm/.glb`，`image/*`，返回 `Access-Control-Allow-Origin: *`
4. **scheme 白名单**：`isUrlSchemeAllowed` 检查 http/https/javascript/data/vbscript，拦截不在白名单的 loadUrl（`loadUrl blocked by scheme whitelist`）
5. **JS 桥痕迹**：`addJavascriptInterface` 存在（例：`javascript:KuYinExtToWeb.share()` 酷音 Web），但 MAML WebView 默认未注入通用桥（v10 实测 window 无注入接口）
6. **useNetwork 拦截**：`loadUrl canceled due to useNetwork setting` — useNetwork 控制联网加载

### 实测结论汇总

| 类别 | 可用 | 不可用 |
|------|------|--------|
| **manifest 参数** | name/x/y/w/h、uri(local)、local、cachePage | uri 在线直载、uriExp 传参(未验证) |
| **命令** | （待排查 RUNJS） | — |
| **HTML 数据** | getBattery+事件、传感器事件、fetch 本地、localStorage、IndexedDB、postMessage、dialog、AudioContext、execCommand copy | 在线 fetch/JSONP/WebSocket、剪贴板读、MediaSession、系统音量 |
| **HTML 网络** | iframe 在线网页（唯一）、本地资源全通 | 在线 img/css/音视频/脚本 |
| **HTML 交互** | 触摸、切页省电、流式滚动 | 锁屏感知、震动、硬件 |
| **渲染** | Canvas2D、WebGL、CSS 动画、JS 定时器 | — |

> ⚠️ RUNJS/uriExp/useNetwork/userAgent 为反编译确认但未实测通过；RUNJS 未生效原因待查（可能 init 时机、params 表达式、WebView 就绪顺序）

## RUNJS 命令正确用法（✅ 已验证 2026-09-10）

> 反编译 `com.miui.maml.commands.WebViewCommand`：command 用小写匹配、params 是 Expression 需单引号

```xml
<ExternalCommands>
  <Trigger action="init">
    <WebViewCommand target="wv" command="runjs" params="'__mamlResume()'" delay="2000"/>
  </Trigger>
  <Trigger action="enterAod">
    <WebViewCommand target="wv" command="runjs" params="'__mamlPause()'"/>
  </Trigger>
  <Trigger action="exitAod">
    <WebViewCommand target="wv" command="runjs" params="'__mamlResume()'"/>
  </Trigger>
</ExternalCommands>
```

### 关键（踩坑总结）

| 坑 | 正确 |
|----|------|
| ❌ `command="RUNJS"` 大写 | ✅ `command="runjs"` **小写**（parseCommand 用 equals("runjs") 精确匹配） |
| ❌ `params="__mamlPause()"` 裸写 | ✅ `params="'__mamlPause()'"` **单引号字符串**（params 是 Expression 类型，裸写被当函数调用） |
| ❌ params 含 `&&` 不转义 | ✅ 避免用 && 或写 `&amp;&amp;`（XML 转义） |
| delay | WebView 异步创建，init 触发建议 delay≥2000，或用 enterAod/exitAod 等页面就绪后的事件 |

### RUNJS 命令列表（反编译确认）

| command | 作用 |
|---------|------|
| `runjs` + params | 执行 HTML 内 JS（evaluateJavascript）✅ 已验证 |
| `reload` | 重新加载页面 |
| `goback` | 返回上一页 |

## window.maml —— HTML→MAML 双向通信（反编译确认）

> 类 `com.miui.maml.elements.web.MamlInterface`，注入名 `"maml"`（addJavascriptInterface）

HTML 里 JS 直接调用 **`window.maml`**：

| 方法 | 作用 |
|------|------|
| `window.maml.getStringByName("变量")` | 读 MAML 字符串变量 |
| `window.maml.getDoubleByName("battery_level")` | 读 MAML 数字变量（电量等系统变量） |
| `window.maml.getObjByName("变量")` / getXxxByIndex(i) | 读对象/按索引 |
| `window.maml.putString("变量","值")` | 写 MAML 字符串变量 |
| `window.maml.putDouble("变量",n)` / putInt / putObj | 写数字/对象变量 |
| `window.maml.registerVariable("变量")` | 注册变量返回索引 |
| `window.maml.doAction("动作")` | 触发 MAML performAction |

```js
// HTML 示例
var batt = window.maml.getDoubleByName('battery_level');  // 读电量
window.maml.putString('html_flag', 'OK');                  // 写变量给 MAML 用
window.maml.doAction('my_action');                         // 触发 MAML 动作
```

### MAML→HTML 与 HTML→MAML 完整链路

```
MAML → HTML:  WebViewCommand command="runjs" params="'JS代码()'"   ✅ 已验证
HTML → MAML:  window.maml.putXxx / doAction                        ⚠️ 反编译确认，待实测
```

## WebView 动态 uri（uriExp）

- `doTick()` 每帧读取 `mUriFormatter.getText()`，与当前 URL 不同则重新 loadUrl
- 即 `uriExp="'web/index.html?b='+int(#battery_level)"` 这类**表达式**，变量变化时**自动重载页面**
- ⚠️ 直接写 `uriExp="web/index.html?b=#battery_level"` 黑屏（非法表达式）；必须按表达式语法拼接

## MAML WebView 框架完整剖析（反编译 2026-09-10）

> 来源：主题管理器 classes2.dex 反编译 `WebViewScreenElement` / `MamlWebView` / `WebViewCommand` / `MamlInterface`

### 1. `<WebView>` 参数（完整）

| 参数 | 解析 | 说明 |
|------|------|------|
| `uri` | getAttribute 原文 | 基础 URL（可含 MAML 变量占位） |
| `uriExp` | **Expression.build 表达式** | 与 uri 组成 TextFormatter，**每帧 doTick 求值，变化自动重载页面** |
| `cachePage` | parseBoolean | 缓存 |
| `local` | parseBoolean | 本地加载（同时决定 setDomStorageEnabled 值） |
| `useNetwork` | "all"→2 / "wifi"→1 / **其他→表达式** | 联网控制，默认 2(all)；可用 `mUseNetworkExp` 动态表达式 |
| `userAgent` | 字符串 | 非空则 setUserAgentString 自定义 UA |
| 进度变量 | name 非空时注册 `<name>.progress` | **MAML 层可用 `#wv.progress` 读加载进度！** |

**uriExp 正确表达式写法**（实测黑屏的坑：直接写 `?b=#battery_level` 是非法表达式）：
```xml
<WebView name="wv" local="true" uri="web/index.html"
    uriExp="'web/index.html?b='+int(#battery_level)+'&amp;t='+int(#time_sys)"/>
<!-- 注意：& 必须转义 &amp;；字符串单引号；变量 int() 包裹 -->
```

### 2. MamlWebView 内置 WebSettings（不可改，框架写死）

```java
setJavaScriptEnabled(true)            // JS 启用
setBuiltInZoomControls(false)         // 禁缩放控件
setSupportZoom(false)                 // 禁缩放（解释为什么不能缩放！）
setInitialScale(100)                  // 初始 100%
setDomStorageEnabled(local)           // DOM 存储 = local 参数
setMediaPlaybackRequiresUserGesture(!local)
setAllowFileAccess(false)             // 禁文件访问
setAllowContentAccess(false)          // 禁 content://
setSupportMultipleWindows(false)
setLongClickable(false)               // 禁长按
setHapticFeedbackEnabled(false)       // 禁触觉
setLayerType(LAYER_TYPE_HARDWARE)     // 硬件层加速（WebGL 流畅）
setHorizontal/VerticalScrollBarEnabled(false)
setOnLongClickListener(禁长按菜单)
MamlWebViewClient  // 资源拦截器（local.widget 域名 + MIME）
MamlWebChromeClient // JS 弹窗/进度
```

> 结论：**缩放被 WebView 层面写死禁止**（supportZoom=false + initialScale=100），viewport meta 只是辅助；JS/DOM 存储/硬件加速已开

### 3. window.maml —— HTML→MAML 接口（注入名 "maml"）

```java
addJavascriptInterface(new MamlInterface(variables, webViewScreenElement), "maml")
```

HTML 调用：
- 读：`window.maml.getStringByName('x')` / `getDoubleByName('battery_level')` / `getObjByName` / `getXxxByIndex(i)`
- 写：`window.maml.putString('x','v')` / `putDouble` / `putInt` / `putObj`
- 注册：`window.maml.registerVariable('x')` / `registerDoubleVariable`
- 动作：`window.maml.doAction('动作名')` → 触发 MAML performAction

### 4. 双向通信链路（完整）

```
MAML → HTML:  <WebViewCommand command="runjs" params="'JS()'"/>   ✅ 已验证
HTML → MAML:  window.maml.putXxx / doAction                       ⚠️ 反编译确认待实测
MAML 读 WebView 状态: #wv.progress 变量（加载进度）
```

### 5. RUNJS 命令速查

| command | params | 作用 |
|---------|--------|------|
| `runjs` | `'JS代码'`（单引号表达式） | 执行 HTML JS ✅ |
| `reload` | — | 重载 |
| `goback` | — | 返回 |

> ⚠️ 踩坑：command 必须小写；params 必须单引号字符串；& 转义；init 触发 delay≥2000

## window.maml + uriExp 实测通过（✅ 2026-09-10 v24）

### uriExp 传参（✅ 成功）

```xml
<WebView name="wv" local="true" uri="web/index.html"
    uriExp="'web/index.html?b='+int(#battery_level)"/>
```

实测：HTML 收到 `location.search = ?b=46`（MAML 电量 46% 成功拼入）！

### window.maml 变量读取（✅ 成功）

HTML 里 `window.maml.getDoubleByName('变量')` 实测结果：

| 变量 | double 值 | 说明 |
|------|-----------|------|
| battery_level | 46 | 电量 ✅ |
| time_sys | 1789005824061 | 毫秒时间戳 ✅ |
| view_width / view_height | 976 / 596 | MAML 布局基准（≠HTML CSS 348） |
| screen_width / screen_height | 596 / 976 | 系统竖屏注册基准 |
| year / month / day / hour / minute / second | 2026 / 8 / 0 / 0 / 3 / 44 | 页面加载快照 |

### ⚠️ 重要事实

1. **只有 `getDoubleByName` 有效**；`getStringByName` 返回 undefined、`getObjByName` 返回 null（MamlInterface 只正确实现 double 读取）
2. **变量是页面加载时的快照**，不实时刷新（year/month/day 等是加载瞬间值）；要拿实时值需配合 uriExp 变化重载或 RUNJS 轮询
3. MAML 的 view_width=976 与 HTML CSS 视口 348 是两套体系（MAML 布局基准 vs WebView 渲染）
4. **HTML→MAML 写变量**（putInt/putString）反编译确认，待用户实测顶部 MAML 文字变化确认

## HTML→MAML 写变量闭环（✅ 2026-09-10 v25 实测）

### 实测结果

```js
// HTML 里
window.maml.putInt('html_num', 1);
var back = window.maml.getDoubleByName('html_num');  // 读回 = 1 ✅
window.maml.putInt('html_num', 2);                    // 读回 = 2 ✅
window.maml.putInt('html_num', 3);                    // 读回 = 3 ✅
```

**HTML 写 MAML 变量 + 读回一致，完全闭环成功！**

- `putInt` / `putDouble`：✅ 写数字变量（读回验证通过）
- `putString`：✅ 写字符串变量（MAML Text 可显示）
- `doAction`：调用成功但返回 undefined（Java void 方法），需 manifest 定义对应 action 触发器才有效果
- `getDoubleByName`：读 MAML 数字变量 ✅（含 battery_level/battery_plug_type 等系统变量）

### HTML↔MAML 双向通信最终链路（全部实测通过）

```
MAML → HTML 控制:   <WebViewCommand command="runjs" params="'JS()'"/>     ✅ v21
MAML → HTML 数据:   uriExp="'web/index.html?b='+int(#battery_level)"      ✅ v24
HTML → MAML 读:     window.maml.getDoubleByName('battery_level')          ✅ v24
HTML → MAML 写:     window.maml.putInt('html_num', n) → 读回一致           ✅ v25
```

> **至此 MAML + WebView 双引擎完全打通**：HTML 可做复杂动画/交互 UI，MAML 负责系统事件/省电/布局，双向数据交换全通。

### 实用场景

- 充电主题：HTML getBattery 真实电量 + uriExp 传 MAML 电量 + putInt 状态回传 MAML 层显示
- 息屏省电：MAML enterAod → RUNJS 暂停 HTML 动画；HTML visibilitychange 兜底
- 数据看板：window.maml 读系统变量（电量/时间/充电状态）在 HTML 里展示
