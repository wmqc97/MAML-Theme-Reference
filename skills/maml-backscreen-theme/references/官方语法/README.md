# MAML 小部件知识库

> 来源：
> - 小部件指南：https://maml-widget-guide.jst.xiaomi.net/
> - 官方语法文档：https://zhuti.designer.xiaomi.com/docs/grammar/

---

## 一、小部件结构（来源：widget-guide）

| 文件 | 内容 |
|------|------|
| [01_结构_旧版小部件.md](./01_结构_旧版小部件.md) | mrc/mtz 包结构说明 |
| [02_结构_新版小部件.md](./02_结构_新版小部件.md) | 新版小部件包结构与 description.xml |

## 二、MAML 语法（来源：widget-guide）

| 文件 | 内容 |
|------|------|
| [03_语法_基础语法.md](./03_语法_基础语法.md) | 变量声明、引用、修改、运算符、内置方法 |
| [04_语法_绘图元素.md](./04_语法_绘图元素.md) | 图片、文字、矩形、元素数组 |
| [05_语法_动画控制.md](./05_语法_动画控制.md) | 差值器动画、序列帧动画、Folme 动画 |
| [06_语法_事件回调.md](./06_语法_事件回调.md) | 按钮事件、动画回调、阈值回调、生命周期、广播回调 |
| [07_语法_命令.md](./07_语法_命令.md) | VariableCommand、AnimationCommand、IntentCommand、BinderCommand |
| [08_语法_逻辑控制.md](./08_语法_逻辑控制.md) | 条件控制、IF语句、循环语句、命令集、方法 |
| [09_语法_数据交互.md](./09_语法_数据交互.md) | 广播订阅/发送、ContentProvider、JSON解析、Bitmap获取 |
| [10_语法_全局状态.md](./10_语法_全局状态.md) | 触摸、屏幕、时间、农历、充电、图片/文本属性、深色模式等全局变量 |
| [11_语法_画布Graphics.md](./11_语法_画布Graphics.md) | Graphics 画布定义、绘图 API、风格填充 |

## 三、适配

| 文件 | 内容 |
|------|------|
| [12_适配_自定义配置.md](./12_适配_自定义配置.md) | var_config.xml 自定义文本/颜色/滑条/图片/时间/开关 |
| [13_适配_多语言.md](./13_适配_多语言.md) | strings_XXX.xml 多语言配置与 RTL 适配 |
| [14_适配_自适应布局.md](./14_适配_自适应布局.md) | 基于 view_width/view_height 的自适应布局 |
| [15_适配_深色模式.md](./15_适配_深色模式.md) | __darkmode 全局变量与深色模式适配 |

## 四、实战与工具

| 文件 | 内容 |
|------|------|
| [16_实战_经验之谈.md](./16_实战_经验之谈.md) | 无障碍、动态帧率、颜色动画、倒影遮罩、反射、微信小程序跳转 |
| [17_工具_开发调试.md](./17_工具_开发调试.md) | 调试工具、VSCode/Sublime 代码补全插件 |

## 五、官方语法文档专有知识库（来源：designer.xiaomi.com）

| 文件 | 内容 |
|------|------|
| [grammar_01_概述与根标签.md](./grammar_01_概述与根标签.md) | MAML 概述、根标签属性、机型适配、应用场景 |
| [grammar_02_变量与数据类型.md](./grammar_02_变量与数据类型.md) | 数据类型、常规变量、数组变量、变量引用与修改 |
| [grammar_03_全局变量完整表.md](./grammar_03_全局变量完整表.md) | 触摸、屏幕、时间、农历、充电、音乐、解锁、指纹、深色模式等全部全局变量 |
| [grammar_04_运算符与内置函数.md](./grammar_04_运算符与内置函数.md) | 运算符、条件判断函数、数学函数、字符串函数、JSON函数、日期差值函数 |
| [grammar_05_文本元素.md](./grammar_05_文本元素.md) | Text 属性完整表、可调用字体、DateTime 格式化代码 |
| [grammar_06_图片元素.md](./grammar_06_图片元素.md) | Image 属性完整表、NumberImage、TimeImage、ImageChars、VirtualScreen |
| [grammar_07_几何图形.md](./grammar_07_几何图形.md) | Rectangle、Ellipse、Circle、Arc、Line、FillShaders/StrokeShaders 渐变 |
| [grammar_08_动画系统.md](./grammar_08_动画系统.md) | 变量动画、元素动画、AnimationCommand、关键帧动画（AnimState/AnimConfig/FolmeCommand）、缓动函数 |
| [grammar_09_混合模式与特效.md](./grammar_09_混合模式与特效.md) | xfermode 混合模式、笔刷、图片变形、音视频（Video） |
| [grammar_10_命令与控件.md](./grammar_10_命令与控件.md) | 可见性命令、声音命令、打开程序、系统开关、Button、Unlocker/Slider、屏下指纹 |
| [grammar_11_外部数据与传感器.md](./grammar_11_外部数据与传感器.md) | ContentProviderBinder、天气/计步/作息/闹钟/日程接口、SensorBinder 传感器 |
| [grammar_12_性能优化与Layer.md](./grammar_12_性能优化与Layer.md) | 性能优化原则、动态帧率、Layer 优化、元素数组、循环命令 |
