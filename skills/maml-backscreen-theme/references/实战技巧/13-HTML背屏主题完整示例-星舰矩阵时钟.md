# HTML 背屏主题完整示例 · 星舰矩阵时钟（Canvas 全自绘）

> 作者：唯梦倾城 | 创建：2026-09-11 | 更新：v1.7 规范同步 | 地位：完整示例代码
> ⚠️ 总纲见 14 号《背屏 Web 主题 · AI 创作规范》（机型避让/作者/手势/流程以此为准）
> 定位：**以后写 HTML 背屏主题直接照抄本示例**。12 号文档讲 WebView 能力边界/双通信，本文件给完整可运行样板 + 写法要点。

---

## 一、适用场景

背屏想要复杂动效（粒子/数字雨/辉光/雷达）时，用 WebView 加载单文件 HTML + Canvas 全自绘，**零外部依赖**（禁在线资源）。主题逻辑：
- HTML：负责所有视觉效果与表现
- MAML(manifest.xml)：负责系统事件(息屏暂停)/手势注入/布局基准

## 二、包结构（rearscreen，必须 zip）

```
星舰矩阵时钟.zip
├── manifest.xml      ← MAML 布局 + WebView + AOD/手势（必）
├── var_config.xml    ← 仅控制项 + 作者信息行，无元数据（必，见 14 号）
├── description.xml   ← 主题信息唯一载体：标题/作者/描述，作者=唯梦倾城（必）
└── web/index.html    ← 全部 HTML/CSS/JS 内联单文件（必）
```

## 三、description.xml（主题信息唯一载体 ★新规范）

**名称/作者/描述只写这里**，var_config.xml 一律不写。rearscreen 包实测用 `<theme>` 根标签（不是 MTZ 的 `<MIUI-Theme>`）：

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<theme>
  <version><![CDATA[1.1]]></version>
  <uiVersion>12</uiVersion>
  <author><![CDATA[唯梦倾城]]></author>
  <designer><![CDATA[唯梦倾城]]></designer>
  <title><![CDATA[星舰矩阵时钟]]></title>
  <description><![CDATA[背屏科技感时钟：深空星云+矩阵数字雨+HUD全息大钟……]]></description>
  <appName/>
  <typeTag></typeTag>
  <frame>0</frame>
  <editable>true</editable>
  <customEditLink>true</customEditLink>
  <resourceType>wallpaper</resourceType>
  <authors><author locale="zh_CN"><![CDATA[唯梦倾城]]></author></authors>
  <designers><designer locale="zh_CN"><![CDATA[唯梦倾城]]></designer></designers>
  <titles><title locale="zh_CN"><![CDATA[星舰矩阵时钟]]></title></titles>
  <descriptions><description locale="zh_CN"><![CDATA[背屏科技感时钟……]]></description></descriptions>
  <appNames/>
</theme>
```

## 四、var_config.xml（仅承载控制项 ★新规范）

```xml
<?xml version="1.0" encoding="UTF-8"?>
<WidgetConfig version="1">
  <OnOff name="miroot_gesture_disable" displayTitle="关闭底部手势" default="0">
    <Language displayTitle="Disable bottom gesture" locale="en_US"/>
    <Language displayTitle="关闭底部手势" locale="zh_CN"/>
  </OnOff>
  <!-- …更多 OnOff/Spinner 控制项… -->
</WidgetConfig>
```
⚠️ **打包后必须检查**：部分打包工具会自动把 name/author/description 注入 var_config，纯 zip 打包（见第八节）可避免；若被注入需手动移除。

## 五、manifest.xml（WebView + AOD + 手势注入）

三段式：① WebView 全屏加载 ② ExternalCommands 息屏暂停。**手势注入层默认不加**（14 号规范），仅用户明确要求时才加（下方完整示例含手势仅供需要时复制）。

```xml
<?xml version="1.0" encoding="UTF-8"?>
<Widget version="2" frameRate="30" scaleByDensity="false" screenWidth="976" transparentSurface="true">
  <WebView name="wv" x="0" y="0" w="#view_width" h="#view_height" local="true" cachePage="true" uri="web/index.html" />
  <ExternalCommands>
    <Trigger action="enterAod"><WebViewCommand target="wv" command="runjs" params="'__setAod(1)'"/></Trigger>
    <Trigger action="exitAod"><WebViewCommand target="wv" command="runjs" params="'__setAod(0)'"/></Trigger>
    <Trigger action="pause">  <WebViewCommand target="wv" command="runjs" params="'__setAod(1)'"/></Trigger>
    <Trigger action="resume"> <WebViewCommand target="wv" command="runjs" params="'__setAod(0)'"/></Trigger>
    <Trigger action="init"><WebViewCommand target="wv" command="runjs" params="'__setAod(0)'" delay="2000"/></Trigger>
  </ExternalCommands>
  <!-- ====== MiRoot 手势注入（底部/右缘/顶部 三区，可整段保留或删除）====== -->
  <Var name="miroot_gesture_disable" type="number" expression="#miroot_gesture_disable"/>
  <Var name="miroot_gesture_disable_right" type="number" expression="#miroot_gesture_disable_right"/>
  <Var name="miroot_gesture_disable_top" type="number" expression="#miroot_gesture_disable_top"/>
  <Layer name="miroot_gesture_inject_bottom" visibility="ifelse(#miroot_gesture_disable,0,1)" layerType="top">
    <Function name="miroot_emit_s1">
      <IntentCommand action="com.wmqc.miroot.rear.ACTION_REAR_BOTTOM_GESTURE" broadcast="true" package="com.wmqc.miroot">
        <Extra name="com.wmqc.miroot.rear.EXTRA_GESTURE_SLOT" type="number" expression="1"/>
      </IntentCommand>
    </Function>
    <!-- …槽位 1/2/3 完整写法见 星舰矩阵时钟/manifest.xml… -->
    <Button name="miroot_bottom_gesture" x="0" y="(#view_height - (80 * (#view_height / 572)))" w="#view_width" h="(80 * (#view_height / 572))" interceptTouch="true">
      <Triggers><Trigger action="up,cancel"><!-- 方向判定 IfCommand --></Trigger></Triggers>
    </Button>
  </Layer>
  <!-- right/top 两区照抄源码 manifest.xml（槽位 4-8） -->
</Widget>
```

## 六、web/index.html（完整源码 v1.1 —— 直接可用模板）

> 全量代码见同目录 **`星舰矩阵时钟/web/index.html`**（和设备主题源文件同一处），下方是**核心写法速查**，完整代码复制以下文件即可：
> `/storage/emulated/0/MiRoot/主题/主题实验区/星舰矩阵时钟/web/index.html`

### 6.1 head 与 CSS（禁缩放 + 全屏 + 避让）

```html
<meta name="viewport" content="width=976, initial-scale=1, maximum-scale=1, user-scalable=no, viewport-fit=cover">
<style>
html,body{margin:0;padding:0;width:100%;min-height:100%;height:100%;overflow-x:hidden;overflow-y:auto;background:#01020a;user-select:none;}
body{padding-left:29vw;box-sizing:border-box;}          /* 内容区避让摄像头（背景可全屏） */
#bg{position:fixed;left:0;top:0;width:100%;height:100%;z-index:0;display:block;}   /* 背景层 */
#fg{position:fixed;left:0;top:0;width:100%;height:100%;z-index:1;display:block;}   /* 前景层 */
</style>
```

### 6.2 布局与避让（核心：动态字号 + 双端夹紧）

```js
function resize(){
  W=window.innerWidth||348; H=window.innerHeight||212;   /* 实测 348x212 = 物理 976x596 ÷ dpr2.8125 */
  DPR=clampi(window.devicePixelRatio||1,1,3);
  SAFE=Math.round(W*0.30);                                /* 29vw 摄像头避让 */
  var availW=(W-SAFE)-12;
  SPR_PX=Math.max(14,Math.min(Math.round(H*0.30),Math.floor(availW/3.5))); /* 字号按可用宽反推=不出右屏 */
  bg.width=Math.round(W*DPR*0.5); bg.height=Math.round(H*DPR*0.5); b.scale(bg.width/W,bg.height/H); /* 背景半分辨率 */
  fg.width=Math.round(W*DPR);     fg.height=Math.round(H*DPR);     c.scale(fg.width/W,fg.height/H);  /* 前景全dpr=锐利 */
}
/* 绘制时钟整体居中 SAFE..W，并夹紧：不出摄像头、不出右屏 */
var x=Math.round(cx-total/2);
if(x<SAFE+4)x=SAFE+4;
if(x+total>W-8)x=W-8-total;
if(x<SAFE+2)x=SAFE+2;
```

### 6.2b 四角 35dp 圆角避让（2026-09-11 用户确认 ★）

背屏**四角有 35dp 圆角**（≈35 个 CSS px，dpr 2.8125 设备上 1dp=1CSSpx）。**贴边角落的元素会被圆角切掉**，规则：

- 顶部状态行/电量条等贴顶元素 → 右、左端至少内收 **38px**（35+余量）：`btx=W-38`
- 右下/左下雷达等装饰 → 右、左端内收 **41px**：`cx=W-41-r`
- 屏幕中部（y≈0.35H~0.75H）贴边内容不受影响（该高度屏幕是直边）
- 摄像头避让（左 29vw）与圆角避让是两套并存规则，都要满足

```js
var btx=W-38;                        /* 电量条右缘：避让右上 35dp 圆角 */
var cx=W-41-r, cy=H-6-r;             /* 雷达：右下内收，右端 ≤ W-41 */
```

### 6.3 高清数字（防模糊的关键 ★）

- **预渲染精灵必须 ×DPR**：精灵画布按物理分辨率建（`tmp.width=Math.round((gw+pad*2)*P)`，`g.scale(P,P)` 后按 CSS 像素画字），否则贴到 dpr=2.8 的 fg 上被放大 2.8 倍 → 发糊
- 辉光收紧（外 blur≈0.32em、内 blur≈0.15em）+ **白芯填充两次** → 亮且实
- 小字（日期/状态/滚动条）直接 fillText + 小 shadowBlur，矢量绘制不糊

### 6.3b ★ drawImage 大坑（v1.2 实测，最易翻车）

**预渲染位图精灵上屏时，drawImage 必须用 9 参数**：

```js
// ❌ 错：5 参数 = 目标尺寸取源像素数 → 在 dpr=2.8 的 fg 上再被 DPR 变换放大 → 尺寸爆炸出屏
c.drawImage(s.cv, x-s.off, y-sprPx);
// ✅ 对：源取全图 + 显式目标 CSS 尺寸（cv.width/DPR）→ 1:1 物理像素，尺寸精确
var cv=s.cv;
c.drawImage(cv,0,0,cv.width,cv.height, x-s.off, y-sprPx, cv.width/DPR, cv.height/DPR);
```

推理：精灵画布已按物理分辨率建（`cv.width=(gw+pad)*DPR`）；5 参形式把"源像素数"当用户坐标尺寸，fg 变换再把用户坐标放大 DPR → 屏幕尺寸 = 源像素×DPR = 设计 CSS 尺寸×DPR²。9 参显式给 CSS 目标宽，变换后 = 源像素 1:1，既清晰又不出屏。

### 6.4 特效与省电骨架

```js
function setAod(mode){var v=(Number(mode)===1||mode===true||mode==='1');if(v===aod)return;aod=v;
  if(aod){drawBG(t);drawFG(t);stopLoop();}else{startLoop();}}   /* MAML RUNJS 调用 */
window.__setAod=setAod;                                          /* 接口名固定，manifest 依赖 */
document.addEventListener('visibilitychange',…)                   /* 切后台兜底暂停 */
/* EMA 帧耗时 >46ms → eco=true 自动关数字雨/网格/雷达（省电自适应） */
```

电池：`navigator.getBattery()` → level/charging + `levelchange`/`chargingchange` 事件（真实值）。
AOD：进入后画一帧静态图即停 rAF（CPU → 0），并用 setTimeout 精确等到下一个整分钟重绘一帧再重排（wvDrawStatic + scheduleAodTick），保证 AOD 期间时间每分钟刷新、画面不冻结；退出 AOD 清定时器恢复 rAF。AOD 下推荐隐藏秒数（gap/ws 归零 + 秒绘制包 if(!aod)），只留 HH:MM 居中，亮屏才显示秒。

## 七、写法要点速查（背屏 HTML 主题通用）

| 主题 | 要点 |
|------|------|
| 视口 | `width=976, maximum-scale=1, user-scalable=no`（框架本身也禁缩放） |
| 全屏/滚动 | `html,body 100% + overflow-x:hidden + overflow-y:auto`；内容多走流式 block |
| 摄像头避让 | 内容 `x≥SAFE=0.30W`；背景特效可全屏 |
| 不出屏幕 | 大元素宽度按可用宽反推字号 + 绘制时双端夹紧 |
| 高清 | 位图类预渲染 ×DPR；文字矢量绘制；fg 全 dpr / bg 半 dpr |
| 文字 | ❌ CSS 渐变文字(background-clip:text)会全透明，一律 canvas |
| 布局 | 用 W/H 比例 + 运行时 resize（Pro/ProMax 通用） |
| 省电 | MAML `__setAod(v)` + visibilitychange + EMA 自动降 ECO |
| 数据 | getBattery 真实电量；禁在线资源（fetch/图片/字体都不行） |
| 通信 | MAML→JS：RUNJS；JS→MAML：window.maml putInt/putString 等（见 12 文档） |

## 八、迭代流程（改完如何装回背屏）

```bash
# 1. 改 web/index.html 后，先语法体检（防黑屏）：
#    把 <script> 内容贴到 QuickJS(new Function) 检查，或设备有 node 则 node --check
# 2. 纯 zip 打包（避免工具注入元数据到 var_config）：
cd /storage/emulated/0/MiRoot/主题/主题实验区/星舰矩阵时钟 && zip -r 星舰矩阵时钟_v1.1.zip . -x '*.bak'
# 3. 校验：miroot_theme_probe 应返回 rear_widget；miroot_maml_validate 应"通过"
#    （WebViewCommand 报未知标签属正常扩展，忽略）
# 4. 安装：miroot_theme_test_install（directory=AI壁纸目录, filePath=zip, keepBackup=true, jumpToSettings=true）
# 5. 系统背屏主题列表 → 重新选择应用
```

> 待办提示：effect.png（picker 缩略图）本包省略，系统封面由 test_install 自动同步 preview；如要 pack 内置缩略图可加 976×596 PNG。

---

## 九、开源项目移植借鉴（2026-09-11 实测「宇宙漫游 v1.8 / 筑间·桌上工地」）

> 包内含 6 个分辨率版本 HTML（1k~11k，761KB~5.4MB）：整体 = Three.js r160 UMD 内嵌（700KB 级）+ 场景代码 + **base64 内嵌纹理**（体积差=纹理精度，是省内存的分档技巧）。已验证**背屏 WebView 可完整跑 Three.js r160*。

### 9.1 值得借鉴的高质量写法

1. **CSS 变量设计系统**（:root 定义 --bg/--surface/--ink/--muted/--primary/--accent，oklch 色彩）→ 全局配色一处改，文字/背景/按钮全跟随
2. **`<meta name="color-scheme" content="dark">`** → 明确深色配色提示
3. **`@media(prefers-reduced-motion:reduce){*{animation:none!important;transition:none!important}}`** → 跟随系统"减少动态效果"，无障碍+省电一举两得（背屏同样适用）
4. **加载遮罩 `#loading`** + **错误兜底 `.error`（onerror）** → 大资源（Three.js/纹理）加载期有进度 UI；WebGL 创建失败显示友好提示而不是黑屏
5. **内置性能自测**（前端按钮触发约 55s benchmark，测黎明/正午/黄昏/夜晚/暴雨各场景帧率并出报告）→ 发布前自检帧率的好范式（可简化为初装后跑 30s 记录 min/avg fps）
6. **响应式断点** `@media(max-width:760px)` / `(max-height:520px)` → 小屏/矮屏布局降级（背屏可直接套用其思路控制字号与元素密度）

### 9.2 移植开源项目的注意点（必做清单）

| 项 | 说明 |
|----|------|
| **适配层自备** | 开源代码**没有**背屏适配：viewport 禁缩放、SAFE 摄像头避让、双层画布、`__setAod` AOD 钩子、AOD 每分钟刷新都要自己加（1k 原版无 __setAod，2k+ 是移植者后加的） |
| **体积** | 内嵌 three.min.js + 纹理使单文件 0.7~5.4MB；zip 压缩后约减半；分档（低中高清 HTML 用 uriExp 切换）是控内存的关键 |
| **viewport 差异** | 原版 `width=device-width,initial-scale=1`（PC 项目习惯）——实际被背屏框架归一化，但我们的规范仍以 `width=976, maximum-scale=1, user-scalable=no` 为准 |
| **字体栈参考** | `-apple-system,BlinkMacSystemFont,"Segoe UI","PingFang SC",sans-serif` 比自造栈更贴近设备 |
| **canvas 数量** | 单 canvas 可行（原版），但双层（bg 半 dpr / fg 全 dpr）在清晰度+省电上更优 |
| **背景铺满** | 3D 场景天然全屏=符合"背景铺满"要求；叠加 HUD 内容仍需 SAFE 避让 |

### 9.3 移植三步流程

```
① 取开源 HTML → 包进 web/index.html（含内嵌库）
② 加背屏适配层：viewport 禁缩放 + SAFE 避让 + __setAod + AOD 定时 + 双层画布改造
③ 按 14 号规范补齐 4 文件 → QuickJS 体检 → 纯 zip → probe/validate → test_install
```
