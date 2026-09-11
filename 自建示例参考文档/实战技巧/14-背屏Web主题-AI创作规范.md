# 背屏 Web 主题 · AI 创作规范（总纲 · 必须遵守）

> 作者：唯梦倾城 | 创建：2026-09-11 | 地位：**最高优先级**。AI 每次创建/修改背屏 Web 主题前先读本文件。
> 用途：让 AI 用"几句指令"就能按统一标准创建 → 避让 → 体检 → 打包 → 安装一条龙。
> 关联：13 号=完整示例代码；12 号=WebView 能力清单；06 号=description/var_config 规范。

---

## 一、目标文件格式（与「星舰矩阵时钟」完全一致）

背屏 Web 主题 = **HTML 加载型**，固定 4 文件、根级 zip：

```
主题名.zip
├── manifest.xml      ← MAML 布局 + WebView(uri=web/index.html) + AOD 暂停（无手势）
├── var_config.xml    ← 仅控制项 + 作者信息行；根标签只写 <WidgetConfig version="1">
├── description.xml   ← 主题信息唯一载体：title/author/designer/description（<theme> 根）
└── web/index.html    ← 全部 HTML/CSS/JS 内联单文件（Canvas 全自绘，零外部资源）
```

任何"加载 HTML 的背屏主题"都按这个模板起步，在此之上加内容。

## 二、机型与布局避让（两款机型通用 ★ 每主题必做）

| 项目 | 数值/规则 |
|------|-----------|
| Pro Max 背屏 | 物理 976×596 横向；WebView CSS 视口 **348×212**；dpr 2.8125 |
| Pro 背屏 | 分辨率未实测，**用 W/H 比例 + 运行时 resize 自适应**（不写死 px） |
| 背景 | **地图铺满全屏**（canvas 全屏绘制） |
| 摄像头 | 左侧 277px 物理≈29vw：**所有可读内容 SAFE=0.30W 之后** |
| 圆角 | 四角 **35dp**（≈35CSSpx）：贴顶/贴边元素右左内收 ≥38px、右下装饰 ≥41px |
| 不出屏 | 大元素宽度按可用宽反推字号 + 绘制时双端夹紧（x≥SAFE+2、右端≤W-8） |
| 不重叠 | 元素按 W/H 比例布局并互留间距；**控件/按钮不得重叠显示** |
| 不明之处 | **弹出选择题问用户**（机型/配色/功能取舍），确认后再写 |

## 三、默认约定（创建时自动应用）

1. **作者**：`description.xml` 的 `author/designer/authors/designers` 一律填 **唯梦倾城**
2. **作者展示**：`var_config.xml` 第一行放作者信息条。**主方案：Text 只读**（displayTitle=作者名 / item=Q群，无开关最干净，v1.8 跑通）：
   ```xml
   <Text name="author_info" displayTitle="✦ 唯梦倾城 ✦" editable="false" maxLength="30" minLength="0">
     <Language displayTitle="✦ 唯夢傾城 ✦" locale="zh_TW"/>
     <Language displayTitle="✦ 唯夢傾城 ✦" locale="zh_HK"/>
     <Language displayTitle="✦ Mengqingcheng ✦" locale="en_US"/>
     <item>Q群 2159063054</item>
   </Text>
   ```
   → 用户打开主题设置第一行即见作者+Q群。备用方案：OnOff 信息行（`displayTitle="✦ 唯梦倾城 · Q群 2159063054 ✦" default="1"`，见 06 号第五节）；Q群号 **2159063054**
3. **手势默认不加**：manifest **不含**手势注入层（仅用户明确要求时才加；MiRoot 有导入自动注入手势功能，勿重复内置）
4. **主题信息**只在 description.xml；var_config 不写 name/author/des
5. **HTML 减少资源占用**（防手机卡顿）：
   - 双层画布：bg 半 dpr（柔光+省电）、fg 全 dpr（文字锐利）
   - 预渲染：数字/图形精灵位图离线绘制（物理分辨率 ×DPR），每帧 drawImage 而非 re-draw
   - drawImage 必须 **9 参数**（否则位图被 DPR 二次放大，尺寸爆炸）
   - 动画套数少而精；重效果（数字雨/网格/雷达）用 EMA 帧耗时自动降级（>46ms → eco 关）
   - AOD 停 rAF 只跑定时器；禁在线资源（字体/图片/fetch 全部不行）

## 四、AOD 息屏方案（2026-09-11 跑通）

- manifest `enterAod/exitAod/pause/resume → RUNJS __setAod(1/0)`；`init → __setAod(0)` delay≥2000
- HTML 端：
  ```js
  function wvDrawStatic(){ var t=(performance.now()/1000)%1000; drawBG(t); drawFG(t); }
  function scheduleAodTick(){ if(!aod)return; var d=new Date();
    var ms=(60-d.getSeconds())*1000-d.getMilliseconds()+50;
    aodTimer=setTimeout(function(){ if(aod){ wvDrawStatic(); scheduleAodTick(); } }, ms); }
  function setAod(m){ var v=(Number(m)===1||m===true||m==='1'); if(v===aod)return; aod=v;
    if(aod){ clearTimeout(aodTimer); wvDrawStatic(); scheduleAodTick(); stopLoop(); }
    else { clearTimeout(aodTimer); startLoop(); } }
  window.__setAod=setAod;   /* 接口名固定 */
  ```
- **AOD 隐藏秒**（gap/ws 归零 + 秒绘制包 `if(!aod)`），只留 HH:MM 居中
- 时间每分钟刷新一帧，不冻结；退出清定时器恢复 rAF；resize 时 aod 态补静态帧
- visibilitychange 兜底：hidden 停 rAF、visible 恢复（aod 时跳过）

## 五、一条龙流程（每次创建/修改都走这套）

```
① 听需求 → 缺信息弹 ask_user（机型/效果/配色/功能取舍）→ 确认
② 在 主题实验区/主题名/ 写 4 文件（套用 13 号模板 + 本规范默认约定）
③ HTML 语法体检：抽 <script> → QuickJS `new Function` 检查（防黑屏）
④ 纯 zip 打包（cd 目录 && zip -r out.zip . -x '*.bak'），**禁用会注入元数据到 var_config 的打包器**
⑤ miroot_theme_probe 确认 rear_widget；miroot_maml_validate 校验（WebViewCommand 报未知标签=正常扩展，忽略）
⑥ miroot_theme_test_install（directory=AI壁纸目录, filePath=zip, keepBackup=true, jumpToSettings=true）
⑦ 用户在系统背屏列表手动应用 → 翻转验证 → 按反馈迭代（改完回到 ③）
⚠️ 改了 HTML 文件一律 ③④⑤⑥ 全走；不要 shell 拼接改代码（曾坏档丢函数）
```

## 六、踩坑速查（10 秒扫一眼）

| 坑 | 对策 |
|----|------|
| drawImage 5 参 | 精灵在 ×DPR 画布上会二次放大 → 一律 9 参并给 CSS 目标宽 cv.w/DPR |
| CSS 渐变文字 | background-clip:text 在背屏 WebView 全透明 → 文字用 canvas 绘制 |
| flex 撑高 | 背屏 WebView 高度塌陷 → 流式 block 布局 |
| 在线资源 | WebView 禁外网 → 全部内联/本地 |
| toybox grep | 不支持 `\|` 交替 → 用固定串分次 grep |
| zip 压缩 | 打包器可能注入元数据 → 纯 zip |
| 手势 | 默认不加；MiRoot 有自动注入，重复内置反而乱 |
