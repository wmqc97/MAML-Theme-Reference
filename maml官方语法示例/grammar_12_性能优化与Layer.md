# 性能优化与 Layer

> 来源：https://zhuti.designer.xiaomi.com/docs/grammar/

---

## 性能优化原则

- 测试时尽量不要用顶配机，frameRate 写60，实测效果：普通手机不低于30帧/s，好一点的手机必须高于40帧/s
- 降低图片文件大小，减少缓存时读取的时间，节省运行内存：存储图片必须导出为 web 格式，或者后期压缩；能用 jpg 绝不用 png，webp 也是很好的选择
- 尽量用合适尺寸的图片，能用小尺寸绝不用大尺寸，有效减少计算量
- 代码逻辑上不要有冲突，必须精简
- 充分利用 `visibility` 控制各模块可见性，只显示当前需要显示的部分

---

## 动态帧率

### 基本用法

```xml
<!-- 根标签设置帧率 -->
<Widget version="2" screenWidth="1080" frameRate="30">
    ...
</Widget>
```

### 充电状态帧率

| 属性 | 代码 |
|------|------|
| `frameRate` | 指定帧率，默认30 |
| `frameRateCharging` | 充电状态下的帧率 |
| `frameRateBatteryLow` | 电量低时的帧率 |
| `frameRateBatteryFull` | 电量满(100%)时的帧率 |

```xml
<Widget frameRate="0" frameRateCharging="60" frameRateBatteryFull="30">
    ...
</Widget>
```

### 动态调整帧率

```xml
<!-- 动画开始前提高帧率，动画结束后降低帧率 -->
<Var name="ani">
    <VariableAnimation loop="false" initPause="true">
        <AniFrame value="0" time="0"/>
        <AniFrame value="1" time="400"/>
        <Triggers>
            <Trigger action="end">
                <FrameRateCommand rate="0"/>
            </Trigger>
        </Triggers>
    </VariableAnimation>
</Var>

<Function name="startAnim">
    <FrameRateCommand rate="120"/>
    <AnimationCommand target="ani" command="play"/>
</Function>
```

> 注意：如果有多个动画需要同时触发，但每个动画时长不一样，应将 `<FrameRateCommand rate="0"/>` 放到耗时最长的那个动画中，或自行维护一个动画栈。

---

## Layer 优化

Layer 是一个 Group，可以单独设置帧率，实现 Layer 内部元素独立于其它部分的单独渲染刷新控制。对应 Android 中的单独一个 View，可以设置 layer 类型来实现 GPU 硬件缓冲，提高绘制性能。

| 属性 | 释义 |
|------|------|
| `hardware` | 是否使用硬件绘图缓冲，true=更快速但更占内存，false=相反 |
| `frameRate` | 指定 Layer 内部元素的帧率 |
| `updatePosition` | Layer 位置（x、y）是否需要更新，true/false，默认 true |
| `updateSize` | Layer 大小（w、h）是否需要更新，true/false，默认 true |
| `updateTranslation` | Layer 的 pivot/rotation/scale/alpha 等属性是否需要更新，true/false，默认 true |

> 如果某些属性值是固定的不需要更新（例如 x 不是表达式，或没有位移动画），设置成 false 会提高性能。

### 优化步骤

1. 当界面某块部分和其它界面部分刷新率不同时，把这块界面元素放到 Layer 中
2. 先尝试 `hardware="false"`，给 Layer 单独指定合适的刷新帧率 `frameRate`
3. 如果还是有问题可以把 `hardware` 设成 `true`（会额外耗费内存）
4. 如果需要 `hardware="true"` 但内存超出预算，Layer 提供 `setHardwareLayer(boolean)` 函数接口，通过 MethodCommand 调用，在动画开始前设为 true，动画结束后设为 false

### 适用情景

- 整体更新频率较高，但部分区域（如日历）不需要频繁更新 → 把这部分放到 Layer 中指定较低帧率
- 整体更新频率较低，但有部分区域有动画需要频繁更新 → 把这部分放到 Layer 单独指定动画帧率
- 较复杂的动画滑进滑出面板，提高动画流畅度 → 用 Layer 设置合适的 hardware 属性

```xml
<!-- 日历面板使用 Layer 单独控制帧率 -->
<Layer x="0" y="200" w="#screen_width" h="400" frameRate="1" hardware="false"
    updatePosition="false" updateSize="false">
    <!-- 日历内容 -->
    <Text x="100" y="100" color="#ffffff" size="40" textExp="@calendar_title"/>
</Layer>

<!-- 动画面板使用 Layer 提高帧率 -->
<Layer x="0" y="0" w="#screen_width" h="200" frameRate="60" hardware="true">
    <!-- 动画内容 -->
    <Image src="anim.png" x="#ani" y="0" w="100" h="100"/>
</Layer>
```

---

## 元素数组（Array）

让界面元素以特定规律的形式展现，避免重复代码。

```xml
<!-- 绘制 10×10 共100个矩形 -->
<Array count="100" indexName="i">
    <Rectangle
        x="#i%10 * 100"
        y="int(#i/10) * 100"
        w="80" h="80"
        fillColor="#ff0000"/>
</Array>
```

| 属性 | 释义 |
|------|------|
| `Array` | 元素数组标签 |
| `indexName` | 索引名称，给各元素编号的变量名 |
| `count` | 元素数组内同类型元素的个数（不支持表达式） |

---

## 循环命令（LoopCommand）

主要与数组配合使用，可节省大量代码，提高效率。

```xml
<Trigger>
    <LoopCommand count="100" indexName="i">
        <VariableCommand name="arr" type="number[]" index="#i" expression="#i * 10"/>
    </LoopCommand>
</Trigger>
```

| 属性 | 释义 |
|------|------|
| `indexName` | 循环计数变量名 |
| `count` | 循环次数 |
| `begin` | 变量到达某个值时开始计算 |
| `end` | 变量到达某个值时终止计算 |
| `loopCondition` | 循环条件，可以用来中断循环 |

```xml
<!-- 带条件的循环 -->
<LoopCommand begin="0" end="99" indexName="i" loopCondition="#i{50">
    <VariableCommand name="loopCount" expression="#i"/>
</LoopCommand>
```
