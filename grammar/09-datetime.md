# 09 - 时间日期

[返回目录](00-index.md)

## 日期格式代码

| 代码     | 说明            | 示例                     |
| -------- | --------------- | ------------------------ |
| A        | 生肖            | 鼠、牛                   |
| G        | 纪元            | 公元                     |
| Y        | 中文年（农历）  | 二〇一五                 |
| YY       | 天干地支年      | 甲子                     |
| yy       | 2位年           | 20                       |
| yyyy     | 完整年          | 2020                     |
| M        | 月              | 1                        |
| MM       | 月（补零）      | 01                       |
| MMM      | 月（中文）      | 九                       |
| MMMM     | 完整月（中文）  | 九月                     |
| N        | 农历月          | 正                       |
| NN       | 天干地支月      | 乙丑                     |
| NNNN     | 完整农历日+节气 | 八月廿八 秋分            |
| D        | 年中第几天      | 168                      |
| d        | 日              | 23                       |
| e        | 农历日          | 初三                     |
| ee       | 天干地支日      | 丙寅                     |
| t        | 节气            | 冬至                     |
| E        | 星期            | 周三                     |
| EEEE     | 完整星期        | 星期三                   |
| EEEEE    | 简短星期        | 三                       |
| H        | 24小时制        | 0~23                     |
| h        | 12小时制        | 0~12                     |
| HH       | 24小时制（2位） | 18                       |
| hh       | 12小时制（2位） | 06                       |
| I        | 地支时辰        | 酉                       |
| m        | 分钟            | 6                        |
| mm       | 分钟（2位）     | 06                       |
| s        | 秒              | 6                        |
| ss       | 秒（2位）       | 06                       |
| S        | 毫秒            | 666                      |
| a        | 上午/下午       | 上午                     |
| aa       | 详细时段        | 上午/下午/傍晚/凌晨/晚上 |
| Z/ZZ/ZZZ | 时区            | +0800                    |
| ZZZZ     | 时区            | GMT+08:00                |
| ZZZZZ    | 时区            | 08:00                    |
| zzzz     | 时区名称        | 中国标准时间             |

**Image 方式的时间日期：**

```xml
<Time x="540" y="400" align="center" alignV="center" src="time.png" space="0" format="HH:mm"/>
```

**Text 方式的时间日期：**

```xml
<DateTime x="540" y="400" align="center" alignV="center" size="200" color="#ffffff" formatExp="ifelse(#time_format,'HH:mm','h:mm')" fontFamily="miui-thin" />
```

DateTime 示例：

```xml
<!-- 农历日期 -->
<DateTime x="20" y="450" color="#000000" size="40" format="Y年N月eH时m分" />
<!-- 今天的日期 -->
<DateTime x="540" y="400" align="center" alignV="center" size="200" color="#ffffff" formatExp="'今天日期：yyyy年MM月dd日'" />
<!-- 指定时间戳 -->
<DateTime x="540" y="400" align="center" alignV="center" size="200" color="#ffffff" formatExp="'明天日期：yyyy年MM月dd日'" value="#time_sys+86400000" />
```
