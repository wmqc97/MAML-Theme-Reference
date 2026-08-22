# 12 - Graphics 画布
[返回目录](00-index.md)

## Graphics 元素

编程式绘制矢量图形，需配合 `GraphicsCommand`。

```xml
<Graphics x="0" y="0" w="480" h="480">
    <GraphicsCommand command="...">
        ...
    </GraphicsCommand>
</Graphics>
```

## GraphicsCommand 指令

### 渐变与样式

```xml
<GraphicsCommand command="createGradientBox" w="200" h="200" 
                 type="linear" 
                 startColor="0xffff0000" endColor="0xff0000ff" 
                 angle="45" />
```

渐变类型：`linear`（线性）、`radial`（径向）、`sweep`（扫描）。
平铺模式 `tile`：`clamp` / `mirror` / `repeat`。

### 路径绘制

```xml
<GraphicsCommand command="lineStyle" thickness="3" color="0xffffffff" alpha="255" />
<GraphicsCommand command="moveTo" x="0" y="0" />
<GraphicsCommand command="lineTo" x="100" y="100" />
<GraphicsCommand command="curveTo" cx="50" cy="0" x="100" y="100" />
<GraphicsCommand command="cubicCurveTo" cx1="50" cy1="0" cx2="100" cy2="50" x="150" y="150" />
```

### 几何图形

```xml
<GraphicsCommand command="drawCircle" cx="100" cy="100" r="50" fillColor="0xffff0000" />
<GraphicsCommand command="drawRoundRect" x="0" y="0" w="100" h="50" rx="10" ry="10" fillColor="0xffff0000" />
```

### 内置元素

也可直接用几何元素标签：

```xml
<Rectangle x="0" y="0" w="100" h="100" fillColor="0xffff0000" strokeColor="0xffffffff" strokeWidth="2" />
<Ellipse x="0" y="0" w="100" h="100" fillColor="0xffff0000" />
<Circle cx="100" cy="100" r="50" fillColor="0xffff0000" />
<Arc x="0" y="0" w="100" h="100" startAngle="0" sweepAngle="90" fillColor="0xffff0000" />
<Line x1="0" y1="0" x2="100" y2="100" strokeColor="0xffffffff" strokeWidth="2" />
```

渐变填充：

```xml
<Rectangle x="0" y="0" w="200" h="200">
    <LinearGradient x1="0" y1="0" x2="200" y2="200" 
                    startColor="0xffff0000" endColor="0xff0000ff" />
</Rectangle>
<Circle cx="100" cy="100" r="50">
    <RadialGradient cx="0.5" cy="0.5" r="0.5"
                    startColor="0xffffffff" endColor="0xff000000" />
</Circle>
```
