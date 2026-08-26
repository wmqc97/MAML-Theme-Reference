# 文本元素（Text / DateTime）

> 来源：https://zhuti.designer.xiaomi.com/docs/grammar/

---

## Text 标签属性

| 属性 | 类型 | 表达式/变量 | 释义 |
|------|------|------------|------|
| `x` | number | o/o | 相对于屏幕左上角的 x 坐标 |
| `y` | number | o/o | 相对于屏幕左上角的 y 坐标 |
| `color` | string | x/o | 文字颜色，支持 `#ffffff`、字符串变量 `@abc`、函数 `argb(255,255,255,255)` |
| `size` | number | o/o | 文字大小 |
| `bold` | boolean | x/x | 粗体，true 表示加粗 |
| `text` | string/number | x/x | 文字显示内容（静态） |
| `textExp` | string/number | o/o | 文字显示内容表达式，支持变量和拼接 |
| `format` | string | x/x | 格式化模板，数字用 `%d`，字符串用 `%s` |
| `paras` | string/number | o/o | 配合 format 使用，多个变量用 `,` 隔开 |
| `width` | number | o/o | 文字宽度，超过时截断；开启多行则折行；开启滚动则滚动显示 |
| `marqueeSpeed` | number | x/x | 文字滚动速度，配合 width 使用 |
| `marqueeGap` | number | x/x | 滚动间隔，文字显示完后再次出现的间隔，默认四个汉字宽度 |
| `rotation` | number | o/o | 旋转角度 |
| `multiLine` | boolean | x/x | 是否支持多行显示，默认 false。开启后支持换行符（`&#10;` 和 `\n`） |
| `spacingMult` | number | x/x | 行距倍数，默认1 |
| `spacingMultExp` | number | o/o | 行距倍数，支持表达式 |
| `spacingAdd` | number | x/x | 行距增加量，默认0 |
| `spacingAddExp` | number | o/o | 行距增加量，支持表达式 |
| `shadowDx` | number | x/x | 水平方向阴影偏移距离 |
| `shadowDy` | number | x/x | 竖直方向阴影偏移距离 |
| `shadowRadius` | number | x/x | 阴影模糊半径 |
| `shadowColor` | string | x/o | 阴影颜色，支持透明度 |
| `align` | string | x/x | 水平对齐方式：`left`、`center`、`right` |
| `alignV` | string | x/x | 垂直对齐方式：`top`、`center`、`bottom` |
| `alpha` | number | o/o | 不透明度 0-255 |
| `visibility` | number/string | o/o | 可见性，`{=0` 不可见，`}0` 可见 |
| `fontFamily` | string | x/x | 指定系统字体 |

### 注意事项

```xml
<!-- textExp 中直接显示文字需要用单引号包裹 -->
<Text textExp="'hello,world!'"/>

<!-- textExp 中使用 string 变量用 @ 引用 -->
<Text textExp="@变量名"/>

<!-- textExp 中使用 number/int/float 变量用 # 引用 -->
<Text textExp="#变量名"/>

<!-- alpha 可以写简单表达式 -->
<Text alpha="255 * 0.8"/>  <!-- 80% 不透明度 -->

<!-- 字符串拼接 -->
<Text textExp="'现在时间是'+#hour12+'点'"/>
```

---

## 可调用字体（fontFamily）

### Mitype（仅支持数字）

| fontFamily 值 | 字重 |
|--------------|------|
| `mitype-thin` | 极细 |
| `mitype-extralight` | 特细 |
| `mitype-light` | 细 |
| `mitype-normal` | 正常 |
| `mitype-regular` | 常规 |
| `mitype-medium` | 中等 |
| `mitype-demibold` | 半粗 |
| `mitype-semibold` | 次粗 |
| `mitype-bold` | 粗 |
| `mitype-heavy` | 极粗 |

### 小米兰亭Pro（支持中文/英文/数字）

| fontFamily 值 | 字重 |
|--------------|------|
| `mipro-thin` | 极细 |
| `mipro-extralight` | 特细 |
| `mipro-light` | 细 |
| `mipro-normal` | 正常 |
| `mipro-regular` | 常规 |
| `mipro-medium` | 中等 |
| `mipro-demibold` | 半粗 |
| `mipro-semibold` | 次粗 |
| `mipro-bold` | 粗 |
| `mipro-heavy` | 极粗 |

---

## DateTime 标签（时间日期格式化）

DateTime 继承自 Text，支持 Text 的所有参数，额外支持以下格式化代码：

| 代码 | 释义 | 示例 |
|------|------|------|
| `A` | 十二生肖年 | 鼠、牛、羊 |
| `G` | 公元 | 公元 |
| `Y` | 汉字年（农历） | 二〇一五 |
| `YY` | 干支年 | 甲子 |
| `yy` | 数字年（2位） | 20 |
| `yyyy` | 数字年 | 2020 |
| `M` | 月 | 1 |
| `MM` | 月（1-9月加0） | 01 |
| `MMM` | 月（汉字） | 九 |
| `MMMM` | 完整月（汉字） | 九月 |
| `N` | 农历月 | 正，二，三 |
| `NN` | 干支月 | 乙丑 |
| `NNNN` | 农历完整日期+节气 | 八月廿八 秋分 |
| `D` | 一年中的第几天 | 168 |
| `d` | 数字日 | 23 |
| `e` | 农历日 | 初三 |
| `ee` | 干支日 | 丙寅 |
| `t` | 二十四节气 | 冬至 |
| `E` | 星期 | 周三 |
| `EEEE` | 星期 | 星期三 |
| `EEEEE` | 星期 | 三 |
| `H` | 24小时制 | 0~23 |
| `h` | 12小时制 | 0~12 |
| `HH` | 24小时制（两位） | 18 |
| `hh` | 12小时制（两位） | 06 |
| `I` | 时辰地支 | 酉 |
| `II` | 时辰地支 | 丁酉 |
| `m` | 分钟 | 6 |
| `mm` | 分钟（两位） | 06 |
| `s` | 秒 | 6 |
| `ss` | 秒（两位） | 06 |
| `S` | 毫秒 | 666 |
| `a` | 上下午 | 上午，下午 |
| `aa` | 上下午（详细） | 上午，下午，傍晚，凌晨，晚上 |
| `Z/ZZ/ZZZ` | 时区 | +0800 |
| `ZZZZ` | 时区 | GMT+08:00 |
| `ZZZZZ` | 时区 | 08:00 |
| `zzzz` | 时区 | 中国标准时间 |

### DateTime 示例

```xml
<!-- 显示当前时间 HH:mm -->
<DateTime x="100" y="100" color="#ffffff" size="80" format="HH:mm"/>

<!-- 显示日期 yyyy年MM月dd日 -->
<DateTime x="100" y="200" color="#ffffff" size="40" format="yyyy年MM月dd日"/>

<!-- 显示星期 -->
<DateTime x="100" y="300" color="#ffffff" size="40" format="EEEE"/>

<!-- 指定时间戳显示（不指定时默认当前时间） -->
<DateTime x="100" y="400" color="#ffffff" size="40" format="yyyy-MM-dd" value="1696089600000"/>
```
