---
name: maml-backscreen-theme
description: >-
  小米手机背屏（后盖屏）MAML 主题开发技能。覆盖 WebView 加载 HTML 到背屏、摄像头避让、
  MediaSession 媒体信息与歌词、AOD 息屏、MAML↔HTML 双向通信、数据绑定、机型适配、打包安装全流程。
  当用户要创建、修改、排障小米背屏主题（.zip/.mrc/.mtz，含 HTML/WebView 型与纯 MAML 型）时使用。
  关键词：背屏主题、后盖屏、MAML、manifest.xml、WebView 加载 HTML、歌词、歌名、MusicControl、
  充电动画、AOD 息屏、摄像头避让、doAction、window.maml、description.xml、var_config。
license: MIT
---

# MAML 背屏主题开发

小米背屏（后盖屏 / 小屏）MAML 主题开发技能，基于多主题实战 + 反编译验证。

## 何时使用

- 创建 / 修改 / 排障小米背屏主题
- 把 HTML / WebView 内容加载到背屏
- 在背屏显示系统数据（电量、存储、步数、天气、媒体信息）
- 背屏音乐主题：歌名 / 歌手 / 进度 / 歌词 / 播放控制
- AOD 息屏、摄像头避让、多机型适配
- 打包、校验、装机测试

## 关键常量（先记住）

| 项 | 值 |
|----|----|
| 背屏物理分辨率 | **976×596**（横向） |
| WebView CSS 视口 | **348×212**，dpr **2.8125** |
| 摄像头避让 | 左侧挖孔 **296px**（物理）≈ **31vw**；`SAFE = 0.30W` |
| 四角圆角 | **101px** 物理（贴顶元素内收 ≥38px） |
| 设计基准 | manifest `screenWidth="976"` + `scaleByDensity="false"` |
| 主题包结构 | `manifest.xml` + `var_config.xml` + `description.xml` + `web/` |
| 打包后缀 | **统一 `.zip`**（严禁 `.zip.zip` / `.mrc.mrc`） |
| **web/ 文件数** | **必须 ≤5**，否则重启黑屏（见 12 号 §9.1） |

## 工作流程

1. **定位文档**：读 [references/00-索引.md](references/00-索引.md)（关键词 → 文件映射），按需只读 1~3 篇。
2. **确认需求**：机型、效果、配色、功能取舍不明确时**先问用户**，不要猜。
3. **写文件**：照抄 [13 号模板](references/实战技巧/13-HTML背屏主题完整示例-星舰矩阵时钟.md) 起步，默认约定见 [14 号规范](references/实战技巧/14-背屏Web主题-AI创作规范.md)。
4. **体检**：HTML 抽 `<script>` 做语法检查（防黑屏）；manifest 做 XML 良构检查。
5. **打包**：`miroot_theme_pack` `format=zip`，`outputName` 写完整名（**不要带 `.zip` 后缀**，工具会自动加）。
6. **装机**：`miroot_theme_test_install` **优先 Hook 直装**（`directApply=true`，需 root + 模块）；失败再走替换流程。
7. **验证**：`md5sum` 比对源包与 `rearScreen/rearscreen_third_*.mrc`；确认 `maml_web_temp` 解压；读日志排查。
8. **改完 HTML 一律重走 4~6 步**，不要用 shell 拼接改代码（曾坏档丢函数）。

## 核心模式速查

### WebView 加载 HTML

```xml
<Widget version="2" frameRate="30" scaleByDensity="false" screenWidth="976" transparentSurface="true">
  <WebView name="wv" x="0" y="0" w="#view_width" h="#view_height"
           local="true" cachePage="true" uri="web/index.html"/>
</Widget>
```
`local="true"` 必须；`transparentSurface="true"` 加在根标签；web/ 里放完整 HTML 项目（相对引用基于 web/）。

### 摄像头 + 圆角避让

```css
html,body{width:100%;height:100%;overflow-x:hidden;overflow-y:auto;margin:0}
body{padding-left:31vw}                 /* 流式布局 */
.safe{position:absolute;left:31vw;top:0;right:0;bottom:0;z-index:10}   /* absolute 布局 */
.wp{position:fixed;left:0;top:0;width:100vw;height:100vh;z-index:0}     /* 背景全屏 */
```

### MAML → HTML

```xml
<!-- 数据：uriExp 变化自动重载（& 要转义 &amp;） -->
<WebView uri="web/index.html" uriExp="'web/index.html?b='+int(#battery_level)"/>
<!-- 控制：command 小写，params 单引号 -->
<WebViewCommand target="wv" command="runjs" params="'__setAod(1)'" delay="2000"/>
```

### HTML → MAML

```js
window.maml.getDoubleByName('battery_level');   // 读数字变量（可靠）
window.maml.getDoubleByName(...);               // 字符串变量读回常为 undefined（WebView 侧）
window.maml.putInt('flag', 1);                  // 写数字
window.maml.doAction('launch_app');             // 触发 WebView 元素内 <Triggers>
```

⚠️ `doAction` 只触发 **WebView 元素内部** 的 `<Triggers>`，**不是** `<ExternalCommands>`。

### 媒体信息与歌词（易错，详见 [20 号](references/实战技巧/20-媒体信息与歌词.md)）

```xml
<MusicControl name="mctl" x="0" y="0" w="10" h="10"
              autoShow="false" enableLyric="true" updateLyricInterval="50" visibility="false"/>
<Var name="mtTitle"  type="string" expression="@mctl.title"/>
<Var name="mtArtist" type="string" expression="@mctl.artist"/>
<Var name="mtState"  type="number" expression="#mctl.music_state"/>
```
- **HTML 内无 MediaSession**，数据须经 MAML 变量传给 HTML
- **歌名优先 `artist`**（实测 = `歌名(版本)-歌手`）；**别用 `title`** —— 蓝牙歌词场景 `title` 是滚动歌词
- **歌词**：先试广播 `line_text` / `lyric_*`，都空则按 `title` **变化频率**判别（变化 ≥2 次 → 歌词），模式**跨歌曲粘滞**
- `<BroadcastBinder>` **必须包在 `<VariableBinders>` 容器内**，写根级不生效

### 生命周期

```xml
<ExternalCommands>
  <Trigger action="init">    <FrameRateCommand rate="60"/> </Trigger>
  <Trigger action="enterAod"><WebViewCommand target="wv" command="runjs" params="'__setAod(1)'"/> </Trigger>
  <Trigger action="exitAod"> <WebViewCommand target="wv" command="runjs" params="'__setAod(0)'"/> </Trigger>
  <Trigger action="pause">   <WebViewCommand target="wv" command="runjs" params="'__setAod(1)'"/> </Trigger>
  <Trigger action="resume">  <WebViewCommand target="wv" command="runjs" params="'__setAod(0)'"/> </Trigger>
</ExternalCommands>
```

### 变量可被命令修改

```xml
<!-- ✅ 用 const="true"：初始化后不每帧重算，但仍可被 VariableCommand 改写 -->
<Var name="btnIdx" type="number" expression="1" const="true"/>
<!-- ❌ 不带 const 的 expression 每帧覆盖写入 → 按钮失灵 -->
```

## 调试方法（背屏无标准调试通道）

**HTML 的 `console.log` 收不到**（`MamlWebChromeClient` 无 `onConsoleMessage`）。可用方案：

```js
/* HTML：写 localStorage */
try{localStorage.setItem("dbg", JSON.stringify({ts:Date.now(), v:someVar}))}catch(e){}
```
```bash
# shell：读 leveldb（三坑：必须经 /proc/<pid>/root、UTF-16LE、log 轮转）
P=$(pidof com.xiaomi.subscreencenter)
D="/proc/$P/root/data/data/com.xiaomi.subscreencenter/app_webview/Default/Local Storage/leveldb"
for f in "$D"/*.log "$D"/*.ldb; do
  iconv -f UTF-16LE -t UTF-8 -c < "$f" 2>/dev/null | grep -ao '{"ts":[^}]*}'
done | tail -20
```

装机校验（客观证据，不靠肉眼）：
```bash
md5sum <源包> /data/system/theme/rearScreen/rearscreen_third_*.mrc   # 应一致
ls -la /data/system/theme_magic/maml_web_temp/                       # 应解压出页面
ls -la /proc/$(pidof com.xiaomi.subscreencenter)/fd | grep rearscreen_third
```

## 环境注意

- 设备无 `git`，同步 GitHub 走 API（见 [scripts/sync_github.sh](scripts/sync_github.sh)）
- toybox `grep` **不支持 `\|` 交替** → 用 `grep -e A -e B` 或分开查
- toybox `awk` 可用；无 `python3` / `zip` / `iconv`（`iconv` 实际有）
- 文件行尾常为 CRLF，比较前先 `tr -d '\r'`
- `sed -i` 对含中文路径的文件正常，但改多变行用 awk 更稳

## 参考文档

- **[references/00-索引.md](references/00-索引.md)** — 关键词 → 文件映射，**优先读这个定位**
- [references/实战技巧/14-背屏Web主题-AI创作规范.md](references/实战技巧/14-背屏Web主题-AI创作规范.md) — 总纲：创建/修改前必读
- [references/实战技巧/15-精华速览与黄金标准.md](references/实战技巧/15-精华速览与黄金标准.md) — 一页纸黄金 10 条
- [references/实战技巧/13-HTML背屏主题完整示例-星舰矩阵时钟.md](references/实战技巧/13-HTML背屏主题完整示例-星舰矩阵时钟.md) — 完整可抄模板
- [references/实战技巧/12-WebView加载HTML到背屏.md](references/实战技巧/12-WebView加载HTML到背屏.md) — WebView 能力边界（含黑屏根因）
- [references/实战技巧/20-媒体信息与歌词.md](references/实战技巧/20-媒体信息与歌词.md) — 歌名/歌手/歌词字段与判别
- [references/实战技巧/07-踩坑记录.md](references/实战技巧/07-踩坑记录.md) — 血泪教训
- [references/基础语法/](references/基础语法) — 变量 / UI / 命令 / 动画
- [references/进阶主题/](references/进阶主题) — GL / 摄像头 / 日程电池 / 官方主题解析
- [references/配置规范/](references/配置规范) — var_config / description.xml
- [references/官方语法/](references/官方语法) — 小米官方 MAML 语法镜像
