# MAML 官方主题深度解析（10 个系统 rearscreen 主题解剖）

> 作者：唯梦倾城 | 创建：2026-09-12 | 学习对象：系统背屏主题下载目录 10 个官方 .mrc（3D相机/频谱/木鱼/天气/獭獭PAG/计步 等，28KB~14.7MB）
> 定位：本文件收录**此前技能未覆盖的官方新元素、控件、参数、技巧**；已有内容不重复。

---

## 一、官方主题结构规范

```
主题.mrc（zip 容器）
├── manifest.xml      ← 根 Widget 属性见下
├── var_config.xml    ← 官方写法：<WidgetConfig version="1" des="说明-可变的变量修改">（des 属性）
├── assets/           ← 资源（images/、GLSL、pag/、weather/、varconfig/ 预览图）
├── strings/          ← 多语言 strings_xx.xml（系统辅助包信息）
└── etc/              ← 自定义字体等（如 c700_regular.ttf）
```

官方根标签常用属性：
```xml
<Widget version="2" screenWidth="1080" screenHeight="684" frameRate="0"
        scaleByDensity="false" displayDesktop="false"
        useVariableUpdater="DateTime.Hour,DateTime.Minute" />
```
- **screenWidth/screenHeight = 1080×684 是官方设计基准**（我们的 976 也兼容，系统按 view 缩放）
- useVariableUpdater 可多值：`DateTime.Hour,DateTime.Minute` / `Battery,DateTime.Minute` / `HyperMaterial,DateTime.Hour,DateTime.Minute`
- frameRate 上限 120（PAG/动画主题用 120，一般 0=跟随系统）

## 二、三机型完整参数（官方注释确认 ★）

| 机型代号 | 物理分辨率 | 宽高比 | 摄像头半径 | srcid |
|----------|-----------|--------|-----------|-------|
| **p2**/popsicle/madrid | 976×596 | ≈1.638 | 102 | 1 |
| **q200**/pandora | 904×572 | ≈1.580 | 98 | 0 |
| **q5**/hongkong | 912×596 | ≈1.530 | 98 | 2 |

识别公式（官方写法，`{`=小于 `}`=大于）：
```xml
<Var name="isHongkong" expression="ifelse(((#view_width/#view_height){1.55),1,0)"/>
<Var name="isP2Physical" expression="ifelse(((#view_width/#view_height)}1.6),1,0)"/>
<Var name="srcid" expression="ifelse(#isHongkong,2,ifelse(#isP2Physical,1,0))"/>
```
- **我们的 小米17 Pro Max = p2（976×596，半径 102）** 与实测一致
- 图片资源多机型后缀：`xxx_0.png`=q200、`xxx_1.png`=p2、`xxx_2.png`=q5（srcid 动态拼文件名）
- MAML 系摄像头避让参考：`x_left = ifelse(#isQ5,300,ifelse(#isP2,320,350)) * #_scale`；另一主题 `contentLeft = (ifelse(#isP2,123,117.5) * dpdx)`

## 三、新元素手册（此前技能未收录）

### 1. SensorBinder（陀螺仪传感器绑定）
```xml
<VariableBinders>
  <SensorBinder name="sensor" rate="1" threshold="0.05" type="gyroscope">
    <Variable name="gyro_x" index="0"/>
    <Variable name="gyro_y" index="1"/>
    <Variable name="gyro_z" index="2"/>
    <Trigger><FunctionCommand target="_calc_camera"/></Trigger>
  </SensorBinder>
</VariableBinders>
```
rate=采样率Hz、threshold=变化阈值触发、index=轴；配合 GL 相机实现**随姿态移动的 3D 背景**。

### 2. BroadcastBinder（系统广播监听）
```xml
<BroadcastBinder action="android.intent.action.TIMEZONE_CHANGED">
  <Trigger><FunctionCommand target="_time_changed"/></Trigger>
</BroadcastBinder>
```
监听任意系统广播（时区/开机/充电等），触发时执行命令。

### 3. FramerateController（时间段帧率控制 ★ 省电神器）
```xml
<FramerateController name="_frameControll" initPause="1" loop="0">
  <ControlPoint frameRate="120" time="0"/>
  <ControlPoint frameRate="120" time="3500"/>
  <ControlPoint frameRate="0" time="3501"/>
</FramerateController>
```
**动画播完自动停帧**：0~3500ms 跑 120fps，3501ms 起 0fps（静止帧不耗电）。比手动 FrameRateCommand 更优雅。

### 4. MultiCommand（条件多命令块）
```xml
<MultiCommand condition="((! eqs(@aod_desk_state,'1')) ** (! #is_pause))">
  <FunctionCommand target="reqApi"/>
  <FrameRateCommand rate="0"/>
</MultiCommand>
```
condition 成立才执行内部多条命令（**= while/if 的组**）。

### 5. Var 数组 + 阈值监视（watch 任意表达式）
```xml
<Var name="daily_weather_type" size="5" type="string[]" const="true"/>
<Var name="colors" type="string[]" values="'#621C00','#1B5C14','#7B34D7','#003CC1'" const="true"/>
<Var name="colorAsset" type="string" expression="@colorAssets[#colorIndex]"/>   <!-- 索引取值 -->
```
**阈值监视**（值变化超过 threshold 触发，可监视任意表达式！）：
```xml
<Var name="watchMinute" expression="#minute" threshold="1">
  <Trigger><FunctionCommand target="reqApi"/></Trigger>
</Var>
```
AOD 下换长阈值（watchMinute2 threshold=15）→ 省电；文本变化监视 `len(@typing_text)` threshold=1。

### 6. PagView / PagCommand（PAG 矢量动画 ★ 官方大量使用）
```xml
<PagView name="cute_pag" w="#pagWidth" h="#pagHeight" layerType="top"
         srcExp="(((('assets/' + @assets) + '/pag/pag_') + #pag_index) + '.pag')"
         loop="1" autoPlay="true" setPath="true" folmeMode="true"
         align="right" alignV="bottom"/>
<PagCommand target="cute_pag" command="play"/>
```
- srcExp 动态拼 PAG 路径（按选项切不同动画）；assets/*/pag/*.pag 是 PAG 矢量动画文件

### 7. GLCommand / Uniform / Property / MethodCommand（GL 渲染主题）
```xml
<GLCommand target="glView" command="render"/>
<GLCommand target="glView" command="setFrameRate" params="0"/>
<Uniform name="..." target="mat" value="@colorPicker"/>   <!-- 改 shader 参数 -->
<MethodCommand target="obj" method="setScale" args="1,1,1"/>
```
- 配合外部 .glsl 素材（assets/*.glsl：fxaa/辉光/模糊/文字 shader 都是文件引入）

### 8. Folme 动画（FolmeState/FolmeConfig/FolmeCommand）
```xml
<FolmeState name="folme_state_0" alpha="0"/>
<FolmeCommand target="aod_bg_target" config="'folme_config_0'" states="'folme_state_0'" command="to"/>
```
官方用 Folme 做 AOD/亮屏两态切换动画（比逐帧动画省电）。

### 9. BinderCommand（天气/计步数据刷新）
```xml
<Function name="reqApi">
  <BinderCommand name="get_weather_hourly_info" command="refresh"/>
  <BinderCommand name="get_weather_daily_info" command="refresh"/>
</Function>
```
配合 watchMinute 整分触发；数据进 `#daily_weather_type/#sunrise/#temperature/#steps_count` 等系统变量。

### 10. Gradient（LinearGradient/GradientStop）+ Rectangle
```xml
<LinearGradient name="bgGradient" angle="0">
  <GradientStop position="0" color="#5BBCFC"/>
  <GradientStop position="1" color="#9AF0E4"/>
</LinearGradient>
```
官方渐变背景标准写法（也可 fillColorExp="json(...)"）。

## 四、var_config 新控件（官方实机验证）

| 控件 | 用途 | 关键属性 |
|------|------|----------|
| **CustomColor** | 主题色选择 | `name displayTitle default="#8ED2CD" index="0"` + `<item>#xxx</item>`(可含 `auto`) |
| **AnimatVar** | 官方模型动画变量 | `name x y scaleX scaleY displayScale` |
| OnOff/Text 增强 | 分组与提示 | OnOff 加 `group="2"`；Text 加 `hint="占位提示"` + `<HintLanguage/>` |
| MultiImageSelect 增强 | 图片多选 | `group`、`width/height`（预览尺寸）、item 加 `contentDescription`、`valueDark` |

- 官方 CustomColor 项里**第一项可以是 `auto`**（自动色）
- `group="N"` 让设置项分组展示

## 五、官方开发技巧精选

1. **state.\* 命名空间**组织全部状态变量（state.wScale=#view_width/976、state.hScale=#view_height/596）
2. **半分辨率缓冲** `bufferScale=0.5`：GL 渲染到 0.5x 缓冲再上屏（与 HTML 双层画布 bg 半 dpr 同理省电）
3. **aod_state 状态机**：0亮屏 / 0.1退出AOD中 / 0.9进入AOD中 / 1完全AOD
4. **无障碍播报**：`<Rectangle contentDescriptionExp="formatDate('HH:mm',#time_sys)" interceptTouch="true" touchable="true"/>` → 背屏可语音播报时间
5. **文本自适应字号**：`#text.text_width` 实测宽度 → 超宽则按比例缩字号（ifelse 算法，见 b3352093）
6. **自定义字体**：etc/*.ttf 打包 + 系统字体路径引用 `'/product/fonts/MiSansRoundedSC.ttf'`（MiSansRoundedSC 圆体、MiSansVF）
7. **天气图标明暗双套**：`assets/weather/0_light.png` + `0_dark.png`（深色模式自动切）
8. **debug 保留**：`<group visibility="0">` 内放 FPS/版本调试 Text，发布不用删
9. **多语言**：Language 全量 17 语言；`ar_EG_#u-nu-latn` 特殊区域码
10. **PAG 做角色/交互动画**（木鱼敲击、獭獭摇摆），比帧序列图省体积且平滑

## 六、与 HTML 主题的关联

- 官方 MAML 主题的一切数据通道（陀螺仪/天气/计步/广播/无障碍）HTML 主题也可通过 **manifest 同款绑定 + RUNJS** 联动
- 摄像头避让三机型公式、1080×684 基准同样适用于 MAML 层辅助布局
- 官方 3D/GL 主题证实背屏 GPU 能力强（GL 120fps），HTML Three.js 完全可行
