# 11 - 高级元素
[返回目录](00-index.md)

## VirtualScreen 虚拟屏幕

创建离屏渲染缓冲区，用于截图或特效。

```xml
<Image src="vs" useVirtualScreen="true" />
```

## 音视频 VideoCommand

MIUI14 限定，用于播放视频/音频。

```xml
<VideoCommand command="play" />
<VideoCommand command="pause" />
<VideoCommand command="seekTo" time="5000" />
```

配置属性：`src`（视频路径）、`loop`（循环）、`volume`（音量 0-1）。

## 混合模式 xfermode

通过 `xfermodeNum` 设置 PorterDuff 混合模式。

| 值 | 模式 | 效果 |
|----|------|------|
| 0 | CLEAR | 清除 |
| 1 | SRC | 只显示源 |
| 2 | DST | 只显示目标 |
| 3 | SRC_OVER | 源覆盖目标 |
| 4 | DST_OVER | 目标覆盖源 |
| 5 | SRC_IN | 源在目标内 |
| 6 | DST_IN | 目标在源内 |
| 7 | SRC_OUT | 源在目标外 |
| 8 | DST_OUT | 目标在源外 |
| 9 | SRC_ATOP | 源在目标上 |
| 10 | DST_ATOP | 目标在源上 |
| 11 | XOR | 异或 |

```xml
<Image x="0" y="0" w="480" h="480" src="mask.png" xfermodeNum="6" />
```

## 笔刷 Paint（刮刮卡效果）

```xml
<Image x="0" y="0" w="480" h="480" src="cover.png" paint="true" />
```

配合触摸事件遍历像素点，实现刮刮卡效果。

## 图片变形 mesh

通过网格顶点控制图片扭曲，配合 `LoopCommand` 动态设置顶点。

```xml
<Image x="0" y="0" w="480" h="480" src="image.png" mesh="true">
    <LoopCommand count="...">
        <!-- 设置顶点 float[] -->
    </LoopCommand>
</Image>
```
