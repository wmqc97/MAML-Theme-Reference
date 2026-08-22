# 16 - 控件
[返回目录](00-index.md)

## Button 按钮

```xml
<Button x="100" y="200" w="100" h="100">
    <Triggers>
        <Trigger action="down">
            <!-- 按下时的操作 -->
        </Trigger>
        <Trigger action="up">
            <!-- 松开时的操作 -->
        </Trigger>
    </Triggers>
</Button>
```

### 动作类型

| action | 说明 |
|--------|------|
| `down` | 按下 |
| `move` | 移动 |
| `up` | 抬起 |
| `double` | 双击 |
| `cancel` | 取消 |

## Slider 滑块

```xml
<Slider x="50" y="200" w="200" h="40" 
        startPoint="0" endPoint="100" 
        value="50" />
```

属性：
- `StartPoint` / `EndPoint`：滑道范围
- `value`：当前值
- 可自定义滑道和滑块图片

## MusicControl 音乐控件

背屏锁屏音乐控制，支持歌曲信息、歌词、播放控制。

```xml
<MusicControl>
    <!-- 歌曲信息 -->
    <Text x="0" y="0" text="#music_title" />
    <Text x="0" y="40" text="#music_artist" />
    <Text x="0" y="80" text="#music_album" />
    
    <!-- 歌词 -->
    <Text x="0" y="120" text="#music_lyric" />
    
    <!-- 进度 -->
    <Text x="0" y="160" value="#music_progress" />
    
    <!-- 专辑封面 -->
    <Image x="0" y="200" src="#music_cover" />
</MusicControl>
```

### 音乐变量

| 变量 | 说明 |
|------|------|
| `#music_title` | 歌曲名 |
| `#music_artist` | 歌手名 |
| `#music_album` | 专辑名 |
| `#music_lyric` | 当前歌词 |
| `#music_cover` | 专辑封面路径 |
| `#music_progress` | 播放进度 |
| `#music_duration` | 总时长 |
| `#music_playing` | 播放状态（0/1） |

### getLyric

获取当前播放位置对应歌词：

```xml
<VariableCommand name="lyric" expression="getLyric(#music_progress)" />
```
