# 图片元素（Image / NumberImage / TimeImage / ImageChars）

> 来源：https://zhuti.designer.xiaomi.com/docs/grammar/

---

## 常规图片（Image）属性

| 属性 | 类型 | 表达式/变量 | 释义 |
|------|------|------------|------|
| `x, y` | number | o/o | 相对于屏幕左上角的坐标 |
| `w, h` | number | o/o | 宽和高 |
| `pivotX, pivotY, pivotZ` | number | o/o | 旋转中心 |
| `rotation` | number | o/o | 旋转角度，一周360度 |
| `rotationX` | number | o/o | X轴旋转角度 |
| `rotationY` | number | o/o | Y轴旋转角度 |
| `rotationZ` | number | o/o | Z轴旋转角度 |
| `scale` | number | o/o | 缩放 |
| `scaleX` | number | o/o | X轴缩放 0~1 |
| `scaleY` | number | o/o | Y轴缩放 0~1 |
| `src` | string | x/x | 图片名称路径 |
| `srcX` | int | o/o | 源图像提取区域左上角 X 坐标 |
| `srcY` | int | o/o | 源图像提取区域左上角 Y 坐标 |
| `srcW` | int | o/o | 从源图像提取区域的宽度 |
| `srcH` | int | o/o | 从源图像提取区域的高度 |
| `srcid` | number/string | o/o | 图片序列后缀数字，如 `src="pic.png" srcid="1"` 则显示 `pic_1.png` |
| `srcExp` | number/string | o/o | 图片源表达式，可与 srcid 一起使用 |
| `srcFormat` | string | x/x | 图片源格式，数字用 `%d`，字符串用 `%s` |
| `srcParas` | number/string | o/o | 图片源参数，多个参数用 `,` 分隔 |
| `alpha` | number | o/o | 透明度 0-255，小于等于0不显示 |
| `antiAlias` | boolean | x/x | 抗锯齿，true 时图片变形旋转不会有锯齿，但速度会慢 |
| `visibility` | number | o/o | 支持表达式，大于0时显示 |
| `align, alignV` | string | x/x | 对齐方式 |
| `blur` | int | x/x | 高斯模糊，值一定要小，否则会卡死 |
| `useVirtualScreen` | boolean | x/x | 启用虚拟屏幕，搭配 VirtualScreen 使用 |
| `loadAsync` | boolean | x/x | 异步加载，false=加载完成后执行，true=执行过程中同步加载 |
| `tint` | string | x/o | 色调（染色），如 `tint="#ffff0000"`（MIUI12新增，支持变量不支持表达式） |
| `tintmode` | int | o/o | 色调混合模式，需与 tint 一起使用，默认5（MIUI12新增） |
| `cornerRadius` | number | x/x | 图片圆角（MIUI14新增，小部件使用） |
| `cornerRadiusExp` | number | o/o | 图片圆角表达式（MIUI14新增，小部件使用） |

### 图片使用示例

```xml
<!-- 基本图片 -->
<Image src="icon.png" x="100" y="100" w="200" h="200"/>

<!-- 根据变量显示不同图片（srcid） -->
<Image src="weather/weather.png" srcid="#weather_id" x="0" y="0" w="100" h="100"/>
<!-- 等效于显示 weather/weather_3.png（当 #weather_id=3 时） -->

<!-- 图片源表达式（srcExp） -->
<Image srcExp="'weather/'+ifelse(#hour24}13,'1','0')+'/weather.png'" srcid="#weather_id" x="0" y="0" w="100" h="100"/>

<!-- 带圆角的图片 -->
<Image src="photo.png" x="0" y="0" w="200" h="200" cornerRadius="20"/>
```

---

## 数字图片映射（NumberImage）

用图片方式显示数字，只需准备 0~9 的十张图片（命名规则：`前缀_0.png`...`前缀_9.png`）。

| 属性 | 变量/表达式 | 释义 |
|------|------------|------|
| `src` | x/x | 图片前缀路径 |
| `number` | o/o | 要显示的数字表达式 |
| `space` | o/x | 显示间隔 |

```xml
<!-- 显示电量数字，使用 num_0.png ~ num_9.png -->
<NumberImage src="num.png" number="#battery_level" x="100" y="100"/>
```

---

## 时间图片（TimeImage）

用图片方式显示时间，需准备 0~9 的数字图片和冒号图片（命名规则：`前缀_0.png`...`前缀_9.png`，冒号为 `前缀_dot.png`）。

```xml
<!-- 显示时间，使用 time_0.png ~ time_9.png 和 time_dot.png -->
<TimeImage src="time.png" x="0" y="0" format="HH:mm"/>
```

`space` 属性控制图片间隙，正值增大间距，负值可使投影重叠节省空间。

---

## 文本图片映射（ImageChars）

把图片拼接在一起显示，解决 `'2019.03.27'` 或 `'Wednesday 03.27'` 等复杂字符串的图片显示问题。

| 属性 | 释义 |
|------|------|
| `src` | 图片前缀路径 |
| `string` | 字符串表达式 |
| `number` | 数字表达式 |
| `space` | 显示间隔 |
| `charNameMap` | 映射列表，用英文逗号分隔，每项第一个字符是原字符，后面是映射字符串 |

常用字符映射：

| 原字符 | 映射名称（图片后缀） |
|--------|------------------|
| `.` | `spot` |
| `:` | `colon` |
| `%` | `pct` |
| ` `（空格） | `space` |

> 注意：因同一目录下图片名称不区分大小写，大写英文命名为两个小写英文字符，如 A 的图片名为 `num_aa.png`

```xml
<!-- 显示 '2019.03.27' -->
<ImageChars src="num.png" string="'2019.03.27'" charNameMap=".:spot"/>
```

---

## 虚拟屏幕（VirtualScreen）

定义的图形元素集合，可以包含几何图形、文本、图片等，用于创建复杂的动画效果或图形布局，并在屏幕上作为整体进行渲染。

```xml
<!-- 定义虚拟屏幕 -->
<VirtualScreen name="v_img" w="#view_width" h="300">
    <Text x="100" y="100" color="#FF00FF" size="100" textExp="'Hello'"/>
    <Image src="icon.png" x="200" y="100" w="100" h="100"/>
</VirtualScreen>

<!-- 使用虚拟屏幕 -->
<Image src="v_img" useVirtualScreen="true"/>

<!-- 虚拟屏幕做倒影（翻转+模糊） -->
<Image src="v_img" useVirtualScreen="true" blur="20" rotationX="180" centerY="300" alpha="100"/>
```

> 注意：虚拟屏幕要有合理的宽高，有持续刷新动画+尺寸太大会导致虚拟屏幕闪烁。
