# 混合模式与特效

> 来源：https://zhuti.designer.xiaomi.com/docs/grammar/

---

## 混合模式（xfermode）

| 属性 | 类型 | 变量/表达式 | 描述 |
|------|------|------------|------|
| `layered` | string | x/x | 和 Group 里面的 xfermode 配合使用，让 xfermode 只作用于 Group 内部的元素 |
| `xfermode` | string | x/x | 混合模式名称 |
| `xfermodeNum` | int | o/o | 混合模式数字，支持变量表达式 |

### xfermode 取值对照

| xfermodeNum | xfermode | xfermodeNum | xfermode |
|-------------|----------|-------------|----------|
| 0 | clear | 6 | dst_in |
| 1 | src | 7 | src_out |
| 2 | dst | 8 | dst_out |
| 3 | src_over | 9 | src_atop |
| 4 | dst_over | 10 | dst_atop |
| 5 | src_in | 11 | xor |
| 12 | add | 13 | Multiply |
| 14 | Screen | 15 | Overlay |
| 16 | Darken | 17 | Lighten |

### 遮罩效果示例

```xml
<!-- 按照 mask.png 的形状对 test.png 进行裁剪 -->
<Group layered="true" w="300" h="300">
    <Image src="test.png" x="0" y="0" w="300" h="300"/>
    <Image src="mask.png" x="0" y="0" w="300" h="300" xfermode="dst_in"/>
</Group>
```

> 注意：在 Group 使用 `layered` 时，必须指定作用区域 `w`、`h`，否则无法生效（混合范围要尽可能小，否则会卡）。一个组里最后一个有 xfermode 的 Image 会将前面所有图片看作一个整体，按照 xfermode 的取值与之混合。

---

## 笔刷（Brush）

笔刷与混合功能搭配，可以做出刮奖、擦玻璃的效果。

| 属性 | 释义 |
|------|------|
| `weight` | 笔刷宽度，支持表达式 |
| `xfermoderow` | 混合模式，参考 Image |
| `w, h` | 宽高，定义此笔刷能涂抹的区域 |

```xml
<!-- 笔刷 + 混合实现刮奖效果 -->
<Group layered="true" w="#screen_width" h="#screen_height">
    <Image src="prize.png" x="0" y="0" w="#screen_width" h="#screen_height"/>
    <Brush weight="#touch_x*0+80" xfermoderow="clear" w="#screen_width" h="#screen_height"/>
</Group>
```

---

## 图片变形（MeshWarp）

通过控制图片节点数组实现图片变形效果。

> 注意：控制图片节点用的数组类型必须为 `float[]`

```xml
<Var name="meshPoints" size="18" type="float[]" const="true"/>
<!-- 设置各节点坐标... -->
<Image src="photo.png" x="0" y="0" w="300" h="300" meshPoints="meshPoints"/>
```

---

## 音视频（Video）（MIUI14新增）

音视频组件用于在百变壁纸和百变锁屏模块中使用音频或视频文件，可实现全屏动画效果。

| 属性 | 类型 | 描述 |
|------|------|------|
| `layerType` | string | `top`=在其他元素之上；`bottom`=在其他元素之下 |

### VideoCommand 控制命令

| 属性 | 类型 | 描述 |
|------|------|------|
| `target` | string | 要控制的元素名称 |
| `command` | string | `pause`=暂停，`play`=播放，`seekTo`=定位，`config`=配置，`setVolume`=音量 |
| `Path` | string | 文件路径（`command="config"` 独有，支持表达式） |
| `loop` | int | 循环模式（`command="config"` 独有）：0=播放一次，1=循环播放 |
| `scaleMode` | int | 缩放模式（`command="config"` 独有）：1=拉伸，2=填充（等比缩放），3=按比例缩放到长或宽 |
| `volume` | float | 音量大小（`command="setVolume"` 独有）：0~1 |
| `time` | number | 定位时间ms（`command="seekTo"` 独有） |

### 视频相关全局变量

| 变量名 | 描述 |
|--------|------|
| `videoName.playState` | 播放状态：`state_error`/`state_idle`/`state_preparing`/`state_prepared`/`state_playing`/`state_paused`/`state_playback_completed` |
| `videoName.duration` | 文件长度（ms），执行过 config 命令后更新 |
| `videoName.position` | 播放位置（ms），播放时动态更新 |

```xml
<!-- 定义视频元素 -->
<Video name="myVideo" x="0" y="0" w="#screen_width" h="#screen_height" layerType="top"/>

<!-- 配置并播放视频 -->
<Trigger action="init">
    <VideoCommand target="myVideo" command="config" Path="'video.mp4'" loop="1" scaleMode="2"/>
    <VideoCommand target="myVideo" command="setVolume" volume="0"/>
    <VideoCommand target="myVideo" command="play"/>
</Trigger>
```

> 注意：
> - 文件大小必须小于50MB
> - 音量默认为0，如需播放声音设置音量为1
> - 音量大于0时，如有其他音源正在播放，会暂停其他音源
> - 在百变壁纸中，如果视频在其他元素之下，需要设置 `layerType="bottom"`，同时在根节点增加 `transparentSurface="true"`
