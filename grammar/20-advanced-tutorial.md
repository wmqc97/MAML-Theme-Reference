# 20 - 高级教程
[返回目录](00-index.md)

## 动态帧率

```xml
<Widget frameRate="0" ...>
```

`frameRate="0"` 表示按需刷新（仅在变量变化时渲染），节省性能。

## Array 元素数组

```xml
<Array name="myArray" count="6" indexName="_idx">
    <Image x="{_idx * 50}" y="0" src="icon_{_idx}.png" />
</Array>
```

- `count`：数组元素数量
- `indexName`：索引变量名，可在子元素中使用

## LoopCommand 循环

```xml
<LoopCommand count="10">
    <VariableCommand name="x" expression="#x + 10" />
    <Image x="#x" y="0" src="dot.png" />
</LoopCommand>
```

`count` 支持表达式。

## 贝塞尔曲线

```xml
<GraphicsCommand command="moveTo" x="0" y="0" />
<GraphicsCommand command="cubicCurveTo" 
                 cx1="50" cy1="0" cx2="100" cy2="50" 
                 x="150" y="150" />
```

## 常亮模式

```xml
<Widget alwaysOn="true" ...>
```

## 全屏壁纸

通过 `#__darkmode_wallpaper` 和 `#__wallpaper_primary_color` 适配全屏壁纸。

## 自定义图片

变量：`@custom_image_path`，用户可在主题设置中自定义图片路径。
