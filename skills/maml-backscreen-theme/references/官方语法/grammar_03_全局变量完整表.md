# 全局变量完整参考表

> 来源：https://zhuti.designer.xiaomi.com/docs/grammar/

---

## 触摸

| 变量名 | 描述 |
|--------|------|
| `#touch_x` | 当前触摸点的 x 坐标 |
| `#touch_y` | 当前触摸点的 y 坐标 |
| `#touch_begin_x` | 按下屏幕时的初始 x 坐标 |
| `#touch_begin_y` | 按下屏幕时的初始 y 坐标 |
| `#touch_begin_time` | 按下屏幕时的时间 |

---

## 屏幕

| 变量名 | 描述 |
|--------|------|
| `#screen_width` | 屏幕宽度 |
| `#screen_height` | 屏幕高度 |
| `#view_width` | 部件宽度（各插件中才使用，比如时钟） |
| `#view_height` | 部件高度 |
| `#raw_screen_width` | 物理宽度（不受根节点 screenWidth 的影响） |
| `#raw_screen_height` | 物理高度 |
| `#view_x` | 部件首次添加位置 x |
| `#view_y` | 部件首次添加位置 y |
| `#wallpaper_offset_pixel_x` | 屏幕偏移的像素数（0 ~ -1×屏幕宽），MIUI13以下支持 |
| `#wallpaper_offset_x` | 屏幕偏移百分比（0 ~ 1.0），MIUI13以下支持 |

---

## 日期时间

| 变量名 | 描述 |
|--------|------|
| `#time` | 当前时间，long |
| `#time_sys` | 系统时间毫秒数 |
| `#year` | 年份 |
| `#month` | 月份（0~11，0表示一月）|
| `#month1` | 月份（1~12，1表示一月）|
| `#date` | 日期（1~31） |
| `#day_of_week-1` | 星期（0=周日，1=周一...6=周六） |
| `#hour12` | 12小时制 |
| `#hour24` | 24小时制 |
| `#minute` | 分钟 |
| `#second` | 秒 |
| `#ampm` | 0=上午，1=下午 |
| `#time_format` | 0=12小时制，1=24小时制 |

> 注意：`#month` 从0开始（0=一月），`#month1` 从1开始（1=一月）

---

## 农历

| 变量名 | 描述 |
|--------|------|
| `#year_lunar` | 农历年份 |
| `#year_lunar1864` | 用来计算天干地支 |
| `#month_lunar` | 农历月份（从0开始计） |
| `#month_lunar_leap` | 是否润月：0不是，1是 |
| `#date_lunar` | 农历日期（从1开始计） |

---

## 充电

| 变量名 | 描述 |
|--------|------|
| `#battery_level` | 当前电量，1~100 |
| `#battery_state` | 0=正常，1=充电，2=电量低，3=已充满 |
| `#ChargeSpeed` | 0=普通充电，1=快充，2=超级快充，3=极速秒充（120w±）（MIUI11开发版支持） |
| `#ChargeWireState` | 11=有线充电，10=无线充电，-1=未充电（MIUI11开发版支持） |

---

## 图片元素属性

> `imageName` 替换为图片标签的 `name` 属性值，如 `<Image name="img" />`

| 变量名 | 描述 |
|--------|------|
| `#imageName.actual_x` | 图片实时位置的 x 坐标 |
| `#imageName.actual_y` | 图片实时位置的 y 坐标 |
| `#imageName.actual_w` | 图片显示宽度 |
| `#imageName.actual_h` | 图片显示高度 |
| `#imageName.bmp_width` | 图片文件的宽度（不受裁切、缩放影响） |
| `#imageName.bmp_height` | 图片文件的高度 |

---

## 文本元素属性

> `textName` 替换为文本标签的 `name` 属性值，如 `<Text name="aa" />`

| 变量名 | 描述 |
|--------|------|
| `#textName.text_width` | 文本宽度，可用来排版 |
| `#textName.text_height` | 文本高度 |

---

## 音乐播放器

> `musicName` 替换为音乐模块定义的名称

| 变量名 | 描述 |
|--------|------|
| `#musicName.music_state` | 音乐播放状态：0=暂停，1=播放 |
| `#musicName.user_rating_style` | 播放源是否是系统默认音乐APP：0=不是，1=是 |
| `@musicName.package` | 当前播放源包名 |
| `@musicName.class` | 当前播放源类名 |
| `@musicName.title` | 歌曲名称 |
| `@musicName.artist` | 歌手名称 |
| `@musicName.album` | 专辑名称 |
| `@musicName.lyric_before` | 已播放的歌词 |
| `@musicName.lyric_after` | 未播放的歌词 |
| `@musicName.lyric_last` | 上一句歌词 |
| `@musicName.lyric_current` | 正在播放的歌词 |
| `@musicName.lyric_next` | 下一句歌词 |
| `#musicName.lyric_current_line_progress` | 当前行歌词的行内播放进度（0~1.0） |
| `#musicName.music_duration` | 歌曲长度（ms） |
| `#musicName.music_position` | 歌曲当前播放位置（ms） |

---

## 解锁控件

| 变量名 | 描述 |
|--------|------|
| `#unlocker.move_x` | 解锁部件在 x 方向的偏移 |
| `#unlocker.move_y` | 解锁部件在 y 方向的偏移 |
| `#unlocker.move_dist` | 解锁部件移动的距离 |
| `#unlocker.state` | 0=正常，1=按下，2=已达到解锁状态 |

---

## 屏下指纹

| 变量名 | 描述 |
|--------|------|
| `#fod_enable` | 系统是否启用屏下指纹：0=关闭，1=开启 |
| `#fod_x` | 指纹区域 x 坐标 |
| `#fod_y` | 指纹区域 y 坐标 |
| `#fod_width` | 指纹区域宽度 |
| `#fod_height` | 指纹区域高度 |
| `#fod_state_msg` | 1=手指按下，2=手指抬起，3=识别失败，4=识别成功 |

---

## 深色模式

| 变量名 | 描述 |
|--------|------|
| `#__darkmode_wallpaper` | 是否开启深色模式且支持调暗壁纸：0=未开启，1=已开启 |
| `#__darkmode` | 是否开启深色模式：0=未开启，1=已开启 |
| `#applied_light_wallpaper` | 壁纸主色调（仅桌面时钟生效）：0=深色，1=浅色 |

---

## 其他

| 变量名 | 描述 |
|--------|------|
| `#sms_unread_count` | 未读短信数 |
| `#call_missed_count` | 未接电话数 |
| `@next_alarm_time` | 下一个闹钟时间 |
| `#volume_level` | 现在音量 |
| `#volume_level_old` | 调节之前的音量（1-15） |
| `#volume_type` | 音量类型：0=通话，1=系统，2=铃声/短信，3=音乐，4=闹钟，5=通知，6=蓝牙通话，7=强制系统，8=DTMF，9=TTS，10=FM。`volume_type>=0` 表示正在调节，调节完毕后值为-1 |
| `#frame_rate` | 当前屏幕帧率 |
| `@__miui_version_code` | MIUI版本（MIUI9=6，MIUI10=8，MIUI11=9，MIUI12=10） |

---

## AOD 息屏专用全局变量

| 变量名 | 描述 |
|--------|------|
| `lunar_calendar_enable` | 农历开关状态：1=显示，0=不显示 |
| `battery_enable` | 电量开关状态：1=显示，0=不显示 |
| `notification_enable` | 通知开关状态：1=显示，0=不显示 |
| `preview_mode` | 1=预览模式，0=息屏模式 |
