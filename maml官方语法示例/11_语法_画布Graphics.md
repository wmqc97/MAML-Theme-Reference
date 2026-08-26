# 画布（Graphics）

> 来源：https://maml-widget-guide.jst.xiaomi.net/widget-graphics.html

Graphics 画布用于在 maml 框架下通过命令绘制各种图形，不通过反射命令即可调用封装好的 Canvas API。适合以前需要大量序列帧才能实现的动画场景。

---

## 定义画布

```xml
<!-- 必须指定高宽 -->
<Graphics name="lineDemo" x="100" y="300" w="1080" h="#screen_height"/>
```

---

## 定义绘图方法

```xml
<Function name="drawLine">
    <!-- 设置绘制线条的颜色与粗细 -->
    <GraphicsCommand target="lineDemo" command="lineStyle" colors="#FFFFFFFF" paramsExp="4"/>
    <!-- 设置线条起始点 -->
    <GraphicsCommand target="lineDemo" command="moveTo" paramsExp="100,100"/>
    <!-- 设置线条结束点 -->
    <GraphicsCommand target="lineDemo" command="lineTo" paramsExp="400,400"/>
</Function>
```

---

## 执行绘图

通过 `setRenderListener` 将画布与绘图方法绑定：

```xml
<Button w="1080" h="#screen_height">
    <Triggers>
        <Trigger action="up">
            <GraphicsCommand target="lineDemo" command="setRenderListener" paramsExp="'drawLine'"/>
        </Trigger>
    </Triggers>
</Button>
```

---

## 绘图 API

| 功能 | 命令 | 参数 |
|------|------|------|
| 画圆 | `drawCircle` | `paramsExp="x,y,r"` |
| 画矩形 | `drawRect` | `paramsExp="x,y,w,h"` |
| 画椭圆 | `drawEllipse` | `paramsExp="x,y,w,h"` |
| 画圆角矩形 | `drawRoundRect` | `paramsExp="x,y,w,h,rx,ry"` |
| 画线起点 | `moveTo` | `paramsExp="x,y"` |
| 画线终点 | `lineTo` | `paramsExp="x,y"`（下一根线以此点为起点） |
| 画二次贝塞尔曲线 | `curveTo` | `paramsExp="控制点x,控制点y,锚点x,锚点y"` |
| 画三次贝塞尔曲线 | `cubicCurveTo` | `paramsExp="控制点1x,控制点1y,控制点2x,控制点2y,锚点x,锚点y"` |

---

## 风格填充

### 单色填充

```xml
<GraphicsCommand target="test" command="beginFill" colors="#ffffff"/>
```

### 渐变填充

```xml
<!-- 先创建渐变矩阵 -->
<GraphicsCommand target="test" command="createGradientBox" paramsExp="起点x,起点y,终点x,终点y,矩阵名字"/>
<!-- 创建着色器 -->
<GraphicsCommand target="test" command="beginGradientFill"
    paramsExp="渐变类型,矩阵名字,着色器名字,拉伸模式"
    colors="#FFFF0000,#FF00FFFF"
    stopsExp="0,1"/>
```

> 渐变类型：1=线性渐变，2=放射渐变
> 拉伸模式：0=clamp拉伸，1=repeat重复，2=mirror镜像

### 单色描边

```xml
<GraphicsCommand target="test" command="lineStyle"
    paramsExp="描边宽,cap,join,miter"
    colors="#ff00ff"/>
```

> cap：0=BUTT无线头，1=ROUND半圆，2=SQUARE方头
> join：0=MITER尖角，1=ROUND圆角，2=BEVEL直线剪切

### 渐变描边

```xml
<!-- 先创建渐变矩阵 -->
<GraphicsCommand target="test" command="createGradientBox" paramsExp="起点x,起点y,终点x,终点y,矩阵名字"/>
<!-- 创建着色器 -->
<GraphicsCommand target="test" command="lineGradientStyle"
    paramsExp="渐变类型,矩阵名字,着色器名字,拉伸模式"
    colors="#FFFF0000,#FF00FFFF"
    stopsExp="0,1"/>
```
