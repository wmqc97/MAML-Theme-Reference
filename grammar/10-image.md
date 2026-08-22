# 10 - 图片
[返回目录](00-index.md)

## Image 元素

MAML 最基础的显示元素，支持本地资源与外部图片。

### 属性

| 属性 | 类型 | 说明 |
|------|------|------|
| `x` / `y` | float | 左上角坐标 |
| `w` / `h` | float | 宽高 |
| `pivotX` / `pivotY` | float | 旋转缩放中心点（0-1），相对自身宽高 |
| `scale` | float | 缩放倍数 |
| `src` | string | 图片资源路径，如 `image.png` 或 `@variable` |
| `srcid` | int | 系统资源 ID |
| `alpha` | 0-255 | 透明度 |
| `blur` | float | 模糊半径（像素） |

## ImageNumber 数字图片映射

将数字字符串映射为分段图片，常用于时间、电量显示。

```xml
<ImageNumber x="100" y="100" 
             src="num_%d.png" 
             value="123" 
             count="10" />
```

- `value`：数字字符串
- `count`：图片总数（0-9 共 10 张）
- 图片命名：`src` 中 `%d` 替换为数字

## ImageChars 文本图片映射

将任意字符串映射为分段图片，常用于冒号、百分号等符号。

```xml
<ImageChars x="100" y="200" 
            src="char_%s.png" 
            value="12:30" 
            charMap=".:spot,:colon,%:pct" />
```

`charMap` 格式：`字符:图片后缀,...`，空格用 `space`。
