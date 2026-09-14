# WebView 加载 HTML 到背屏主题

> 🆕 2026-09-11 实测：背屏 WebView 可完整运行 Three.js r160（UMD 整库内嵌 + base64 纹理，单文件 761KB~5.4MB，宇宙漫游验证）；开源项目移植要点见 13 号第九章，多分辨率分档用 uriExp 切换。
> 验证日期：2026-09-09 ~ 09-14（含 XP 桌面主题 v2.8：doAction 唤起应用 + HTML 侧 AOD 反编译破解）
> 状态：✅ 已验证可行（星际航海 / 涨水充电 / 网络测试 / XP 桌面多个主题实测）
> 🆕 2026-09-14 反编译破解：`doAction` 只触发 WebView 内 `<Triggers>`（非 ExternalCommands）；AOD 息屏必须 HTML 侧实现（非 MAML `<Aod>` 元素），详见文末第六~八章

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
HTML → MAML:  window.maml.putXxx / doAction                        ✅ 已实测（doAction 触发 WebView 内 Triggers）
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
HTML → MAML:  window.maml.putXxx / doAction                       ✅ 已实测（doAction 触发 WebView 内 Triggers）
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
- `doAction`：触发 **WebView 元素内 <Triggers> 的 <Trigger action="xxx">**（精确匹配，见下方「三、纯MAML启动应用」反编译铁证）；返回 undefined（Java void）
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

---

# XP 桌面主题实战经验（2026-09-14 · v2.3）

> 作者：唯梦倾城（Q群 2159063054）
> 来源：Windows XP 复古桌面主题（WebView + HTML 完整交互桌面）多轮实测
> 位置：/storage/emulated/0/MiRoot/主题/主题实验区/XP桌面主题/

## 一、摄像头避让：absolute 布局方案（重要）

星舰矩阵时钟用 `body{padding-left:29vw}`（流式布局有效），但 **XP 桌面是 absolute 定位布局**，`body padding` 对 absolute 子元素无效，必须用**安全区容器**：

```css
/* 错误：absolute 布局下 body padding 无效 */
body{padding-left:29vw}  /* 对 position:absolute 的子元素不起作用 */

/* 正确：.safe 容器 + 内部定位 */
.safe{position:absolute;left:29vw;top:0;right:0;bottom:0;z-index:10}  /* 安全区 = 右71% */
.wp{position:fixed;left:0;top:0;width:100vw;height:100vh;z-index:0}   /* 背景全屏可覆盖摄像头 */
```

**关键结论**：
- **背景层**用 `position:fixed;inset:0` 全屏（可被摄像头覆盖，不影响观感）
- **所有可交互内容**放 `.safe`（left:29vw）容器内，用 absolute 定位
- 内容居中 = 相对 safe 计算，如窗口宽 60vw 居中 `left:(71-60)/2=5.5vw`（相对 safe），视口位置 29+5.5=34.5vw
- 图标中间偏右 = `.safe` 内 `left:6vw` → 视口 35vw

## 二、MAML 系统变量传递（存储/开机时长/步数）

参照「能效标识主题」的 ContentProviderBinder 写法，用 **MAML 变量 + window.maml.getDoubleByName 读取**：

```xml
<!-- manifest.xml 关键片段 -->
<Var name="uptimeMs" type="number" expression="#time"/>  <!-- 开机时长: 系统时间戳毫秒 -->

<VariableBinders>
  <!-- 存储: securitycenter 提供 availableSpace/totalSpace(字节) -->
  <ContentProviderBinder name="getStorageData" uri="content://com.miui.securitycenter.widgetProvider/getCleanMasterData" columns="availableSpace,totalSpace" countName="hasStorageData">
    <Variable name="_availableSpace" type="long" column="availableSpace"/>
    <Variable name="_totalSpace" type="long" column="totalSpace"/>
  </ContentProviderBinder>
  <!-- 内存占用 -->
  <ContentProviderBinder name="getMemoryData" uri="content://com.miui.securitycenter.widgetProvider/getMemoryData" countName="hasGetMemoryData">
    <Variable name="_memoryOccupied" type="long" column="memoryOccupied"/>
  </ContentProviderBinder>
  <!-- 步数: 小米健康 -->
  <ContentProviderBinder name="MiSteps" uri="content://com.mi.health.provider.main/activity/steps/brief" columns="steps,goal" countName="hasSteps">
    <Variable name="MiSteps_steps" type="int" column="steps"/>
    <Variable name="MiSteps_goal" type="int" column="goal"/>
  </ContentProviderBinder>
</VariableBinders>

<ExternalCommands>
  <Trigger action="init"><BinderCommand name="getStorageData" command="refresh"/></Trigger>
  <Trigger action="exitAod"><BinderCommand name="getStorageData" command="refresh"/></Trigger>
  <Trigger action="resume"><BinderCommand name="getStorageData" command="refresh"/></Trigger>
</ExternalCommands>
```

```js
// HTML 里读 MAML 变量
function mamlVar(name){
  try{ if(window.maml && typeof window.maml.getDoubleByName==='function'){
    var v=window.maml.getDoubleByName(name);
    if(v!==null&&v!==undefined&&!isNaN(v))return v;
  }}catch(e){}
  return null;
}
// 存储: 字节 -> GB
var totalGB = mamlVar('_totalSpace')/(1024*1024*1024);
var availGB = mamlVar('_availableSpace')/(1024*1024*1024);
// 开机时长: 毫秒 -> 天/时/分/秒
var uptimeSec = mamlVar('uptimeMs')/1000;
// 步数
var steps = mamlVar('MiSteps_steps');
```

## 三、纯 MAML 启动应用（IntentCommand）—— 反编译验证版

> ⚠️ 2026-09-14 反编译背屏中心（com.xiaomi.subscreencenter）源码确认，本节为**最终正确结论**

**背屏 Web 主题点击图标启动系统应用，用纯 MAML 语法**（等价 `am start -n 包名/Activity`）。

### ✅ 正确写法（关键：Trigger 必须放 WebView 元素内部！）

```xml
<!-- 正确：<Trigger> 放 <WebView> 元素的 <Triggers> 内部 -->
<WebView name="wv" x="0" y="0" w="#view_width" h="#view_height" local="true" cachePage="true" uri="web/index.html">
  <Triggers>
    <Trigger action="launch_kuwo">
      <IntentCommand action="android.intent.action.MAIN" package="cn.kuwo.kwmusiccar" class="cn.kuwo.kwmusiccar.ui.WelcomeActivity"/>
    </Trigger>
  </Triggers>
</WebView>
```

```js
// HTML 点击触发（action 名精确匹配）
window.maml.doAction('launch_kuwo');
```

### ❌ 错误写法（doAction 不触发 ExternalCommands！）

```xml
<!-- 错误：doAction 不会触发 ExternalCommands 里的 Trigger -->
<ExternalCommands>
  <Trigger action="content_1">
    <IntentCommand .../>
  </Trigger>
</ExternalCommands>
```

### 反编译铁证（MamlInterface 源码）

```java
// doAction 只调用 WebViewScreenElement 自己的 performAction
public void doAction(String action) {
    mWebViewScreenElementRef.get().performAction(action);
}

// performAction 只触发该元素的 mTriggers（元素内 <Triggers>）
public void performAction(String action) {
    if (mTriggers != null && action != null) {
        mTriggers.onAction(action);
        requestUpdate();
    }
}

// onAction → isAction → 精确字符串匹配（String.equals）
public boolean isAction(String action) {
    for (String s : mActionStrings) {
        if (s.equals(action)) return true;  // 精确匹配，不是前缀
    }
    return false;
}
```

**核心结论**：
- `window.maml.doAction('xxx')` → 触发 **WebView 元素自身 `<Triggers>` 内 `<Trigger action="xxx">`**（精确字符串匹配）
- **不是** `<ExternalCommands>` 的 Trigger，**不是** `<Button>` 的 OnClick
- `<IntentCommand action="android.intent.action.MAIN" package="xx" class="xx"/>` = 等价 `am start -n xx/xx`，纯 MAML 原生启动（无需 MiRoot 广播）
- 查询包名/Activity：`cmd package resolve-activity --brief -c android.intent.category.LAUNCHER <包名>`，或 `pm path <包名>` + `dumpsys package <包名> | grep LAUNCHER`
- 酷我车机版 = `cn.kuwo.kwmusiccar` + `.ui.WelcomeActivity`

### MiRoot 广播拉起背屏应用（备选方案）

MiRoot 的 `ACTION_LAUNCH_APP_ON_REAR` 是给 **`startService`** 用的（不是广播！），且依赖 Root/Shizuku 特权通道：

```bash
# 正确调用方式（startservice 而非 broadcast）
am startservice -a com.wmqc.miroot.rear.ACTION_LAUNCH_APP_ON_REAR \
  --es packageName cn.kuwo.kwmusiccar \
  --ez launchFromRearDesktop true \
  -n com.wmqc.miroot/.rear.RearAppLaunchService
```

反编译 `RearAppLaunchService` 确认：需要 `rootReady=true` 或 `shizukuRunning&&shizukuGranted`，否则 `"no privileged shell channel, skip rear launch"` 直接跳过。MAML 主题里优先用上面的 IntentCommand 方案，MiRoot 广播只做备选。

## 四、XP 桌面交互经验（窗口拖动/显示桌面/托盘点击）

### 1. 窗口拖动坐标陷阱（必踩坑）

窗口是 `.safe`（left:29vw）子元素时，`style.left` 是**相对 safe 的坐标**，而 `getBoundingClientRect()` 返回**视口坐标**，必须换算：

```js
// 拖动开始: 视口坐标 -> safe 内坐标
var r = w.getBoundingClientRect();
w.style.left = (r.left - SAFE_LEFT) + 'px';   // 关键: 减 SAFE_LEFT！

// 拖动移动: 同样减 SAFE_LEFT
var maxL = (innerWidth - SAFE_LEFT) - w.offsetWidth;
w.style.left = Math.max(0, Math.min(maxL, (x - ox) - SAFE_LEFT)) + 'px';
```

**错误写法**（窗口飞出屏幕拖不回来）：`w.style.left = r.left`（视口值当 safe 内坐标用）。

### 2. 窗口居中定位

```css
/* 不用 transform 居中（背屏 WebView 兼容问题），用明确 left */
.win{width:60vw; left:5.5vw}  /* (71-60)/2 = 5.5vw, 相对 safe 居中 */
```

### 3. 显示桌面（点托盘时间隐藏所有窗口）

```js
function showDesktop(){
  Object.keys(winEls).forEach(function(id){
    winEls[id].classList.add('hidden');
    winEls[id].classList.remove('min');
  });
  Object.keys(taskBtn).forEach(function(id){ taskBtn[id].classList.remove('active'); });
  closeMenu();
}
// 点托盘时间触发
clockEl.addEventListener('click', function(){ showDesktop(); showToast('显示桌面'); });
```

**坑**：窗口恢复时 `toggleWin` 必须 `remove('min','hidden')`（两个都清），否则 `showDesktop` 加的 `hidden` 没清，任务栏按钮点不回来。

### 4. 提示 toast 在安全区居中

```css
.toast{left:64.5vw; transform:translateX(-50%)}  /* (29+100)/2=64.5vw, 安全区中心 */
/* 不是 left:50%！50% 是视口中心，会偏左进摄像头区 */
```

## 五、其他踩坑

1. **heredoc 写 HTML 单引号**：`cat > file <<'EOF'`（引号 EOF）单引号不被 shell 转义；用 `sed` 含单引号的替换容易出错，**整文件重写比多次 sed 打补丁更可靠**
2. **sed 跨行替换**：toybox sed 不支持 `\n` 在匹配模式里，跨行替换会失败，改用行号 `sed -i 'Ns/.../'` 或 `sed -i 'N,Nd'` + 插入
3. **图标双击会息屏**：背屏系统把双击映射为息屏，桌面图标必须**单击即开**，不要做双击交互
4. **35dp 圆角**：屏幕右下角有物理圆角，托盘/时间要留 `padding-right` 避让（约 2.5vw~4vw），不是右边距 9vw 那么多
5. **经典 XP 四色旗**：用 SVG 波浪平行四边形（红绿蓝黄 + 渐变），不是 2×2 方块，也不是一排四块
6. **MAML 变量是加载快照**：`window.maml.getDoubleByName` 读的是页面加载时的值，要实时需配合 `BinderCommand refresh` + 重新读取

---

# HTML 唤起安卓应用 + AOD 息屏（2026-09-14 反编译破解 · v2.8）

> 关键突破：反编译背屏中心 `com.xiaomi.subscreencenter` 的 `MamlInterface`，彻底搞清 `doAction` 机制和 AOD 正确方案。

## 六、HTML 唤起安卓应用（doAction 机制破解）

### ⚠️ 核心结论：doAction 只触发 WebView 元素内部的 Triggers，不是 ExternalCommands！

之前一直以为 `window.maml.doAction('content_1')` 触发 `<ExternalCommands><Trigger action="content_1">`，**这是错的**。

### 反编译铁证（MamlInterface 源码）

```java
// com.miui.maml.elements.web.MamlInterface
public void doAction(String action) {
    // 1. 从 WeakReference 拿 WebViewScreenElement
    // 2. 只调用它自己的 performAction
    mWebViewScreenElementRef.get().performAction(action);
}

// com.miui.maml.elements.ScreenElement
public void performAction(String action) {
    if (mTriggers != null && action != null) {
        mTriggers.onAction(action);   // 只触发「该元素」的 mTriggers
        requestUpdate();
    }
}

// com.miui.maml.CommandTrigger
public boolean isAction(String action) {
    for (String s : mActionStrings) {   // action 属性(逗号分隔多值)
        if (s.equals(action)) return true;   // 精确字符串匹配
    }
    return false;
}
```

### 正确写法：Trigger 放在 WebView 元素内部

```xml
<Widget version="2" frameRate="30" scaleByDensity="false" screenWidth="976" transparentSurface="true">
  <!-- ✅ 正确: Triggers 在 WebView 元素内部 -->
  <WebView name="wv" x="0" y="0" w="#view_width" h="#view_height" 
           local="true" cachePage="true" uri="web/index.html">
    <Triggers>
      <Trigger action="launch_kuwo">
        <IntentCommand action="android.intent.action.MAIN" 
                       package="cn.kuwo.kwmusiccar" 
                       class="cn.kuwo.kwmusiccar.ui.WelcomeActivity"/>
      </Trigger>
    </Triggers>
  </WebView>
  <!-- ❌ 错误: 放 ExternalCommands 里 doAction 触发不到 -->
  <!-- <ExternalCommands><Trigger action="content_1">...</Trigger></ExternalCommands> -->
</Widget>
```

```js
// HTML 里
window.maml.doAction('launch_kuwo');  // 精确匹配 WebView 内 <Trigger action="launch_kuwo">
```

### 完整链路

```
HTML: window.maml.doAction('launch_kuwo')
  → MamlInterface.doAction('launch_kuwo')
  → WebViewScreenElement.performAction('launch_kuwo')
  → CommandTriggers.onAction('launch_kuwo')
  → CommandTrigger.isAction('launch_kuwo')  精确 equals 匹配
  → 执行 <IntentCommand> 启动应用 ✅
```

### 查应用包名/Activity 的方法

```bash
pm path <包名>                                    # 找 apk 路径
cmd package resolve-activity --brief -c android.intent.category.LAUNCHER <包名>
# 或 dumpsys package <包名> | grep LAUNCHER
```

### MamlInterface 完整方法表（反编译确认）

| 方法 | 说明 | 可用 |
|------|------|------|
| `doAction(String)` | 触发 WebView 元素内 Triggers（精确匹配 action） | ✅ 本功能 |
| `getDoubleByName(String)` | 读 MAML 数字变量 | ✅ |
| `getDoubleByIndex(int)` | 按索引读数字变量 | ✅ |
| `putInt(String,int)` / `putDouble` / `putString` / `putObj` | 写 MAML 变量 | ✅ |
| `getStringByName/ByIndex` | 读字符串变量（实测返回 undefined） | ⚠️ |
| `getObjByName/ByIndex` | 读对象变量（实测返回 null） | ⚠️ |
| `registerVariable/registerDoubleVariable` | 注册变量 | — |

## 七、AOD 息屏：HTML 侧实现（不用 MAML <Aod> 元素）

### ⚠️ 核心结论：背屏 WebView 主题的 AOD 必须 HTML 侧实现，MAML <Aod> 元素在背屏 WebView 场景不生效！

参考「漫游宇宙」主题，正确链路是 **MAML 检测 enterAod → RUNJS 通知 HTML → HTML 切 AOD 画面**。

### manifest 写法

```xml
<ExternalCommands>
  <Trigger action="enterAod">
    <WebViewCommand target="wv" command="runjs" params="'__setAod(1)'"/>
  </Trigger>
  <Trigger action="exitAod">
    <WebViewCommand target="wv" command="runjs" params="'__setAod(0)'"/>
  </Trigger>
  <Trigger action="pause">
    <WebViewCommand target="wv" command="runjs" params="'__setAod(1)'"/>
  </Trigger>
  <Trigger action="resume">
    <WebViewCommand target="wv" command="runjs" params="'__setAod(0)'"/>
  </Trigger>
  <Trigger action="init">
    <WebViewCommand target="wv" command="runjs" params="'__setAod(0)'" delay="2000"/>
  </Trigger>
</ExternalCommands>
```

### HTML 写法

```html
<!-- AOD 画面(黑底蓝屏待机风, 内容 left:29vw 避摄像头) -->
<div id="aod">
  <div class="aod-safe">
    <div class="aod-xp">Windows XP</div>
    <div class="aod-time" id="aodTime">--:--</div>
    <div class="aod-date" id="aodDate">----</div>
    <div class="aod-foot">
      <span id="aodSteps">步数 --</span>
      <span id="aodBattery">电量 --%</span>
    </div>
  </div>
</div>
```

```js
window.__setAod = function(v){
  if(Number(v)===1||v===true||v==='1'){
    aodRefresh();                    // 刷新时间/步数/电量
    $('#aod').classList.add('show'); // 显示 AOD
  } else {
    $('#aod').classList.remove('show');
  }
};
/* 息屏时定时刷新(省电: 30秒一次) */
setInterval(function(){ if($('#aod').classList.contains('show')) aodRefresh(); }, 30000);
```

### AOD 设计要点

1. **黑底**（`#000000`）OLED 最省电，`frameRate=1`
2. **字体加大**：背屏视口高 212px，AOD 大时钟约 19vh（~40px）才醒目，步数/电量 6vh
3. **避摄像头**：内容在 `left:29vw` 安全区内居中
4. **数据实时**：用 `window.maml.getDoubleByName` 读系统变量（`#battery_level` 电量、`#MiSteps_steps` 步数）

## 八、MiRoot 背屏启动应用广播（另类方案，需特权通道）

`com.wmqc.miroot.rear.ACTION_LAUNCH_APP_ON_REAR` 是 MiRoot 的背屏启动应用方案，但：

- **必须用 `am startservice` 而非 `am broadcast`**（IntentService 不是广播接收器）
- **依赖 Root/Shizuku 特权 Shell 通道**（日志 `route=ROOT`），无特权会 skip
- 在主题里用纯 MAML `doAction` 更直接，不需要 MiRoot 广播
- 反编译确认：`RearAppLaunchService.handleLaunchAppOnRearIntent` 检查 `rootReady`/`shizukuGranted`，无特权则「skip rear launch」

**结论**：主题内唤起应用优先用 **`<WebView>` 内 `<Triggers>` + `doAction`**，最简单可靠，不依赖 MiRoot 特权通道。
