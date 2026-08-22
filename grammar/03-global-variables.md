# 03 - 全局变量

[返回目录](00-index.md)

## 触摸变量

| 变量              | 说明              |
| ----------------- | ----------------- |
| #touch_x          | 当前触摸 x 坐标   |
| #touch_y          | 当前触摸 y 坐标   |
| #touch_begin_x    | 按下时初始 x 坐标 |
| #touch_begin_y    | 按下时初始 y 坐标 |
| #touch_begin_time | 按下时的时间      |

## 屏幕变量

| 变量                      | 说明                                                        |
| ------------------------- | ----------------------------------------------------------- |
| #screen_width             | 屏幕宽度                                                    |
| #screen_height            | 屏幕高度                                                    |
| #view_width               | 小部件宽度                                                  |
| #view_height              | 小部件高度                                                  |
| #raw_screen_width         | 物理宽度（设备分辨率，不受根标签 screenWidth 影响）         |
| #raw_screen_height        | 物理高度                                                    |
| #view_x                   | 小部件首次添加位置 x                                        |
| #view_y                   | 小部件首次添加位置 y                                        |
| #wallpaper_offset_pixel_x | 屏幕偏移像素（0 到 -1*screen_width）。**仅 MIUI13 及以下** |
| #wallpaper_offset_x       | 屏幕偏移百分比（0~1.0）。**仅 MIUI13 及以下**               |

## 日期变量

| 变量           | 说明                            |
| -------------- | ------------------------------- |
| #time          | 当前时间，long                  |
| #time_sys      | 系统时间毫秒                    |
| #year          | 年                              |
| #month         | 月（0~11，0=一月）              |
| #month1        | 月（1~12，1=一月）              |
| #date          | 日（1~31）                      |
| #day_of_week-1 | 星期几（0=周日，1=周一…6=周六） |
| #hour12        | 12小时制                        |
| #hour24        | 24小时制                        |
| #minute        | 分钟                            |
| #second        | 秒                              |
| #ampm          | 0=上午，1=下午                  |
| #time_format   | 0=12小时制，1=24小时制          |

## 农历变量

| 变量              | 说明                   |
| ----------------- | ---------------------- |
| #year_lunar       | 农历年                 |
| #year_lunar1864   | 用于天干地支计算       |
| #month_lunar      | 农历月（从 0 开始）    |
| #month_lunar_leap | 闰月：0=非闰月，1=闰月 |
| #date_lunar       | 农历日（从 1 开始）    |

## 充电变量

| 变量             | 说明                                                |
| ---------------- | --------------------------------------------------- |
| #battery_level   | 当前电量（1~100）                                   |
| #battery_state   | 电池状态：0=正常，1=充电中，2=低电量，3=满电        |
| #ChargeSpeed     | 充电速度：0=普通，1=快充，2=超快充，3=极速（120w±） |
| #ChargeWireState | 充电方式：11=有线，10=无线，-1=未充电               |

## 图片变量

（将 `imageName` 替换为 Image 标签的 name 属性）

| 变量                  | 说明                          |
| --------------------- | ----------------------------- |
| #imageName.actual_x   | 实时 x 坐标                   |
| #imageName.actual_y   | 实时 y 坐标                   |
| #imageName.actual_w   | 显示宽度                      |
| #imageName.actual_h   | 显示高度                      |
| #imageName.bmp_width  | 文件宽度（不受裁剪/缩放影响） |
| #imageName.bmp_height | 文件高度                      |

## 文本变量

（将 `textName` 替换为 Text 标签的 name 属性）

| 变量                  | 说明     |
| --------------------- | -------- |
| #textName.text_width  | 文本宽度 |
| #textName.text_height | 文本高度 |

## 音乐变量

（将 `musicName` 替换为 MusicControl 标签的 name 属性）

| 变量                         | 说明                               |
| ---------------------------- | ---------------------------------- |
| #musicName.music_state       | 播放状态：0=暂停，1=播放中         |
| #musicName.user_rating_style | 是否为系统默认音乐 App：0=否，1=是 |
| @musicName.package           | 当前来源包名                       |
| @musicName.class             | 当前来源类名                       |

## 解锁变量

| 变量                | 说明                             |
| ------------------- | -------------------------------- |
| #unlocker.move_x    | x 方向偏移                       |
| #unlocker.move_y    | y 方向偏移                       |
| #unlocker.move_dist | 移动距离                         |
| #unlocker.state     | 状态：0=正常，1=按下，2=解锁到达 |

## 屏下指纹变量

| 变量           | 说明                                                     |
| -------------- | -------------------------------------------------------- |
| #fod_enable    | 系统开启屏下指纹：0=关，1=开                             |
| #fod_x         | 指纹区域 x 坐标                                          |
| #fod_y         | 指纹区域 y 坐标                                          |
| #fod_width     | 指纹区域宽度                                             |
| #fod_height    | 指纹区域高度                                             |
| #fod_state     | 指纹状态：0=抬起，1=按下，2=滑动，3=识别失败，4=识别成功 |
