# MAML 概述与根标签

> 来源：https://zhuti.designer.xiaomi.com/docs/grammar/

---

## MAML 概述

MAML（MIUI Application Markup Language for MORE）是 MIUI MORE 引擎应用标记语言。

- 最初用于百变锁屏，使用 XML 特定语法描述锁屏界面
- 后演化成接近通用的界面描述语言和图形渲染引擎
- 支持：显示时间日期、查询 ContentProvider 获取天气等信息、图片文本元素、各种动画、滑动点击等交互控件
- 适于实现展示信息或有简单交互操作的界面，如时钟、天气小部件、闹钟响铃界面

**动态帧率机制**：没有动画和更新时停止渲染，仅占用极少资源；缓慢变化的动画使用低帧率，高动态动画开始后立即调整到高帧率全速渲染（60-120帧）。

---

## 根标签属性

| 属性 | 类型 | 释义 |
|------|------|------|
| `frameRate` | int | 指定帧率，默认30。动画缓慢可指定小值省电 |
| `screenWidth` | int | 设定屏幕宽度标准。如指定720，所有元素按720p布局编写，其他分辨率自动缩放 |
| `useHardwareCanvas` | boolean | 为支持硬件加速的设备开启硬件加速（MIUI13新增） |
| `width` | int | 图标宽度（动态图标独有） |
| `height` | int | 图标高度（动态图标独有） |
| `hideApplicationMessage` | boolean | 控制是否隐藏应用程序通知标志（动态图标独有） |
| `useVariableUpdater` | string | 变量更新器触发时机 |
| `displayDesktop` | boolean | 透视到桌面（目前系统已不支持） |
| `showSysWallpaper` | boolean | 是否显示桌面壁纸（目前系统已不支持） |

### useVariableUpdater 可选值

| 值 | 触发时机 |
|----|---------|
| `Battery` | 电池状态发生变化时 |
| `DateTime.Day` | 每天一次 |
| `DateTime.Hour` | 每小时一次 |
| `DateTime.Minute` | 每分钟一次 |
| `DateTime.Second` | 每秒一次 |

可组合使用：`useVariableUpdater="Battery,DateTime.Minute"`

---

## 在个性化中的应用

### 百变锁屏
主题包 `lockscreen/advance` 目录下，`manifest.xml` 为描述脚本。

### 百变壁纸
主题包 `miwallpaper` 目录下，描述文件也是 `manifest.xml`。

壁纸偏移变量：
- `#wallpaper_offset_pixel_x`：屏幕偏移像素数（0 ~ -1×屏宽），MIUI13以下支持
- `#wallpaper_offset_x`：屏幕偏移百分比（0 ~ 1.0），MIUI13以下支持

壁纸自适应设计方式：
1. 将壁纸切成双屏宽
2. 壁纸定位：`x="-#wallpaper_offset_x * 屏宽"`
3. 跟随滑动的元素：`x="-#wallpaper_offset_x * 屏宽 + 相对壁纸的位置"`

### 动态图标
主题包 `icons\fancy_icons\` 目录下，每个动态图标是一个以 app 包名命名的文件夹，包含 `manifest.xml`。

---

## 机型适配

### 资源适配

```
extraResources="sw1000-den320:den320:1.2"
```
- `sw1000-den320:den320:1.2`：屏宽1000密度320的机型，使用den320文件夹下的资源，放大1.2倍
- `sw1000-den320::1.2`：屏宽1000密度320的机型，使用默认资源，放大1.2倍

### 适配原理
1. 列出所有自定义中出现的 den 和 sw 列表
2. 拿设备密度去 den 列表中找最贴近的一个
3. 同样 den 有多个 sw 时，再拿设备屏宽找最贴近的
4. 取对应目录下的资源及缩放比例
