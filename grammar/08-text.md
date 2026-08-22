# 08 - 文本

[返回目录](00-index.md)

```xml
<Text x="50" y="500" align="center" alignV="center" color="#ffffff" size="48" textExp="'hello,world!'"/>
```

## 文本属性

| 属性         | 类型          | 说明                                 |
| ------------ | ------------- | ------------------------------------ |
| x, y         | number        | 位置坐标                             |
| color        | string        | 文本颜色（#hex、@变量或 argb 函数）  |
| size         | number        | 字体大小                             |
| bold         | boolean       | 粗体                                 |
| format       | string        | 格式字符串（%d 代数字，%s 代字符串） |
| paras        | string/number | 格式占位符的变量                     |
| text         | string/number | 静态文本内容                         |
| textExp      | string/number | 文本表达式（支持变量）               |
| width        | number        | 文本宽度（截断/滚动）                |
| marqueeSpeed | number        | 滚动速度                             |
| marqueeGap   | number        | 滚动间隙（默认：4 个中文字符宽度）   |
| rotation     | number        | 旋转角度                             |
| multiLine    | boolean       | 启用多行显示                         |
| spacingMult  | number        | 行距倍数                             |
| spacingAdd   | number        | 行距增量                             |
| shadowDx     | number        | 阴影水平偏移                         |
| shadowDy     | number        | 阴影垂直偏移                         |
| shadowRadius | number        | 阴影模糊半径                         |
| align        | string        | 水平对齐                             |
| alignV       | string        | 垂直对齐                             |
| shadowColor  | string        | 阴影颜色                             |
| alpha        | number        | 不透明度 0-255                       |
| visibility   | number/string | 可见性（>0 = 可见）                  |
| fontFamily   | string        | 系统字体指定                         |

## 可用字体

**Mitype（仅数字）：** mitype-thin、mitype-extralight、mitype-light、mitype-normal、mitype-regular、mitype-medium、mitype-demibold、mitype-semibold、mitype-bold、mitype-heavy

**小米兰亭 Pro（中英文/数字）：** mipro-thin、mipro-extralight、mipro-light、mipro-normal、mipro-regular、mipro-medium、mipro-demibold、mipro-semibold、mipro-bold、mipro-heavy
