# 14 - 动画
[返回目录](00-index.md)

## VariableAnimation 变量动画

```xml
<VariableAnimation variable="alpha" fromValue="0" toValue="255" 
                   duration="1000" curve="easeInOut" 
                   initPause="true" loop="true" />
```

- `initPause`：初始暂停
- `loop`：循环播放
- `curve`：缓动曲线（20+ 种）

## 数组动画

```xml
<VariableAnimation variable="position" 
                   values="0,100,0" 
                   duration="2000" />
```

## 元素动画

六种类型：

| 类型 | 说明 |
|------|------|
| `SourcesAnimation` | 图片源切换 |
| `PositionAnimation` | 位置变化 |
| `SizeAnimation` | 尺寸变化 |
| `AlphaAnimation` | 透明度变化 |
| `RotationAnimation` | 旋转 |
| `ScaleAnimation` | 缩放 |

## AnimationCommand

```xml
<AnimationCommand command="play" animation="anim1" />
<AnimationCommand command="pause" animation="anim1" />
<AnimationCommand command="resume" animation="anim1" />
<AnimationCommand command="play" animation="anim1" 
                  start="0" end="1000" loop="true" delay="500" />
```

## MIUI13 Folme 关键帧动画

```xml
<AnimState name="state1">
    <AnimConfig variable="x" from="0" to="100" />
</AnimState>
<AnimState name="state2">
    <AnimConfig variable="x" from="100" to="0" />
</AnimState>
<FolmeCommand command="state1" />
```

## 缓动函数

内置曲线：`linear`、`easeIn`、`easeOut`、`easeInOut`、`easeExp`……

自定义缓动：`easeExp="#__ratio*#__ratio"`。

**颜色值必须使用 `0xffffffff` 格式，`beginning` 不能填 `#` 开头。**
