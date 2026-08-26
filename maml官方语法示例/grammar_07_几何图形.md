# 几何图形

> 来源：https://zhuti.designer.xiaomi.com/docs/grammar/

在内存要求高的场景下，使用绘制几何图形的方式替代 `<Image>` 以减小内存。

---

## Rectangle（矩形/圆角矩形）

| 属性 | 类型 | 表达式/变量 | 释义 |
|------|------|------------|------|
| `x, y` | number | o/o | 图形起始点（Rectangle 为左上角，其余几何图形均为中心点） |
| `w, h` | number | o/o | 宽和高 |
| `strokeColor` | string | x/o | 描边颜色 |
| `fillColor` | string | x/o | 填充色 |
| `weight` | number | o/o | 描边的线宽 |
| `cap` | string | x/x | 线头形状：`butt`=无线头（默认），`round`=半圆，`square`=方形 |
| `dash` | number | x/x | 虚线模式，格式 `"线长,间隔,线长,间隔..."` |
| `strokeAlign` | string | x/x | 描边对齐方式：`inner`=内描，`center`=中心描边，`outer`=外描（默认） |
| `xfermode` | int | o/o | 混合模式，与 Image 相同 |
| `cornerRadius` | number | x/x | 倒角半径，格式 `"x向半径,y向半径"` |
| `cornerRadiusExp` | number | o/o | 倒角半径，支持表达式 |
| `align, alignV` | string | x/x | 对齐方式（只有 Rectangle 支持） |
| `visibility` | number | o/o | 可见性 |
| `alpha` | number | o/o | 透明度 0-255 |

```xml
<!-- 基本矩形 -->
<Rectangle x="0" y="0" w="200" h="100" fillColor="#ff0000"/>

<!-- 圆角矩形 -->
<Rectangle x="0" y="0" w="200" h="100" fillColor="#ff0000" cornerRadius="20,20"/>

<!-- 带描边的矩形 -->
<Rectangle x="0" y="0" w="200" h="100" fillColor="#ff0000" strokeColor="#ffffff" weight="2"/>

<!-- 虚线矩形 -->
<Rectangle x="0" y="0" w="200" h="100" strokeColor="#ffffff" weight="2" dash="10,5"/>
```

---

## FillShaders 与 StrokeShaders（渐变着色器）

填充着色器和描边着色器语法一致，支持：线性渐变、放射渐变（径向渐变）、扫描渐变（圆周渐变）、位图着色。

### LinearGradient（线性渐变）

| 属性 | 类型 | 表达式/变量 | 释义 |
|------|------|------------|------|
| `x, y, x1, y1` | number | o/o | 渐变轴线 (x,y) → (x1,y1) |
| `tile` | string | x/x | 铺展模式：`clamp`=拉伸（默认），`mirror`=镜像，`repeat`=重复 |

```xml
<Rectangle x="0" y="0" w="#view_width" h="300">
    <FillShaders>
        <LinearGradient x="0" y="0" x1="0" y1="300" tile="clamp">
            <GradientStop color="#ff0000" position="0"/>
            <GradientStop color="#0000ff" position="1"/>
        </LinearGradient>
    </FillShaders>
</Rectangle>
```

### RadialGradient（放射渐变）

| 属性 | 类型 | 表达式/变量 | 释义 |
|------|------|------------|------|
| `x, y` | number | o/o | 圆心位置 |
| `rX, rY` | number | o/o | x、y 方向的半径 |

```xml
<Circle x="200" y="200" r="100">
    <FillShaders>
        <RadialGradient x="200" y="200" rX="100" rY="100">
            <GradientStop color="#ffffff" position="0"/>
            <GradientStop color="#000000" position="1"/>
        </RadialGradient>
    </FillShaders>
</Circle>
```

### SweepGradient（扫描渐变）

| 属性 | 类型 | 表达式/变量 | 释义 |
|------|------|------------|------|
| `x, y` | number | o/o | 中心点位置 |
| `rotation` | number | o/o | 旋转角 |

### GradientStop（渐变点）

| 属性 | 类型 | 表达式/变量 | 释义 |
|------|------|------------|------|
| `color` | string | x/o | 渐变点的颜色 |
| `position` | number | o/o | 渐变点位置，0~1.0 的浮点数 |

---

## Ellipse（椭圆）

```xml
<Ellipse x="200" y="200" w="300" h="200" fillColor="#ff0000"/>
```

---

## Circle（圆）

```xml
<Circle x="200" y="200" r="100" fillColor="#ff0000"/>
```

---

## Arc（扇形/弧线）

```xml
<Arc x="200" y="200" r="100" startAngle="0" sweepAngle="270" strokeColor="#ffffff" weight="5"/>
```

---

## Line（直线）

```xml
<Line x="0" y="0" x1="200" y1="200" strokeColor="#ffffff" weight="2"/>
```

---

## 注意事项

- 对齐方式 `align`/`alignV`：只有 Rectangle 支持，其他几何图形的 x、y 都是中心点位置
- 线条类图形（Line、Arc）忽略 `fillColor` 和 `<FillShaders>`
- 有面积的图形同时支持 stroke 和 fill
- 优先级：`<StrokeShaders>` 优先于 `strokeColor`；`<FillShaders>` 优先于 `fillColor`
- 要出现描边，`strokeColor` 和 `<StrokeShaders>` 必须至少一个存在
- `<LinearGradient x="" y="">` 中的 x、y 都是相对它所在的图形元素定位的
