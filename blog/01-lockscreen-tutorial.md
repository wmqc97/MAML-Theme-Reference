# 锁屏入门教程

> 来源：https://zhuti.designer.xiaomi.com/docs/blog/LockScreenGettingStarted.html

## 前期准备

本教程主要面向未接触过代码的小米主题设计师，让大家在很短的时间内学会 MAML 语言，写出自己的第一个锁屏。

要求：

1. 下载编辑器、示例锁屏包、代码编辑工具
2. 打开编辑器，将"示例锁屏包"拖拽到编辑器面板的任意位置

## 坐标

MAML 坐标起点位于屏幕左上角。X 轴从左到右，Y 轴从上到下，与 Photoshop、Sketch 等设计工具一致。

用代码编辑器打开 `manifest.xml`，添加如下示例代码：

```xml
<?xml version="1.0" encoding="UTF-8"?>
<Lockscreen version="2" frameRate="30" screenWidth="1080">
    <Image src="bg.jpg" x="0" y="0" />
</Lockscreen>
```

关键参数：

- **frameRate**：帧率
- **screenWidth**：分辨率
- **Image**：图片标签
- **src**：图片路径名（仅支持 advance 文件夹下的文件）
- **x, y**：坐标
- 图片支持 jpg、webp、png 格式，1080×1920 分辨率

## 时钟（Time）

在背景图片后添加时间代码。在 MAML 中，先写的代码在下面，像砌墙一样：

```xml
<?xml version="1.0" encoding="UTF-8"?>
<Lockscreen version="2" frameRate="30" screenWidth="1080">
    <Image src="bg.jpg" x="0" y="0" />
    <Time x="540" y="230" src="time.png" space="20"/>
</Lockscreen>
```

关键参数：

- **Time**：时钟标签
- **align**：对齐模式（left、center、right）
- **space="20"**：数字图片之间的间距
- 时钟图片路径使用下划线前的部分（如文件 `a_0.png` → 代码使用 `a.png`）

## 日期（DateTime）

```xml
<?xml version="1.0" encoding="UTF-8"?>
<Lockscreen version="2" frameRate="30" screenWidth="1080">
    <Image src="bg.jpg" x="0" y="0" />
    <DateTime x="540" y="420" align="center" format="M月d日 E aa" size="40" color="#ffffff" alpha="220" />
</Lockscreen>
```

关键参数：

- **DateTime**：日期标签
- **format**：标准日期格式（如显示为"5月12日 周四 下午"）
- **size**：文字大小
- **color**：RGB 颜色值
- **alpha**：透明度（0~255，0 为透明）

## 解锁（Unlocker）

在开发者选项中开启"显示布局边界"以辅助参考。

**重要提示：** 解锁坐标现在需要相对坐标来适配不同屏幕分辨率的机型。

```xml
<?xml version="1.0" encoding="UTF-8"?>
<Lockscreen version="1" frameRate="30" screenWidth="1080">
    <!-- 背景 -->
    <Image x="0" y="0" src="bg.jpg" />
    <!-- 时间 -->
    <Time x="540" y="230" align="center" src="time/time.png" space="20"/>
    <!-- 日期 -->
    <DateTime x="540" y="420" align="center" format="M月d日 E aa" size="40" color="#ffffff" />

    <!-- 箭头 -->
    <Image x="540" y="#screen_height-130+#unlocker.move_y" align="center" src="arrow.png" alpha="255" />
    <!-- 解锁 -->
    <Unlocker name="unlocker" bounceInitSpeed="1500" bounceAcceleration="3000">
        <StartPoint x="390" y="#screen_height-200" w="300" h="200" />
        <EndPoint x="390" y="#screen_height-600" w="300" h="100">
            <Path x="0" y="0" tolerance="800">
                <Position x="390" y="#screen_height-200" />
                <Position x="390" y="#screen_height-500" />
            </Path>
        </EndPoint>
    </Unlocker>
</Lockscreen>
```

关键参数：

- **unlocker.move_y**：解锁组件 y 方向偏移量
- **name**：定义组件名（如 "unlocker" 或自定义名称如 "abc"）
- **StartPoint**：手指触摸拖拽的起始区域
- **EndPoint**：StartPoint 必须滑动到的目标区域
- **w**：宽度（像素）
- **h**：高度（像素）
- **Path**：滑动方向和最大距离
- **tolerance**：临界值，超过此值取消解锁操作

解锁仅在点击 StartPoint 范围内触发，然后沿定义的路径拖拽。当 StartPoint 左上角到达 EndPoint 目标区域时，释放手指完成解锁。Path 必须正确书写，tolerance 临界值不应过小，否则无法解锁。

## 解锁示例 2（使用 anchorX、anchorY）

```xml
<Unlocker name="unlocker">
    <StartPoint x="390" y="1720" anchorX="150" anchorY="100" w="300" h="200" />
    <EndPoint x="340" y="1420" w="300" h="200">
        <Path tolerance="800">
            <Position x="390" y="1720" />
            <Position x="390" y="1470" />
        </Path>
    </EndPoint>
</Unlocker>
```

此示例使用 anchorX 和 anchorY 修改解锁触发点位置。不传这些参数时，默认为左上角。

---

_最近更新时间：2021/11/17_
