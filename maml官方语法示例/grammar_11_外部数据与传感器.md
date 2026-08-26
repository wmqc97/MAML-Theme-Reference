# 外部数据与传感器

> 来源：https://zhuti.designer.xiaomi.com/docs/grammar/

---

## VariableBinders

定义各种变量绑定到的源。支持 `ContentProviderBinder`、`SensorBinder`、`BroadcastBinder`。

> 注意：一个 XML 文件中只能存在一个 `VariableBinders`，多个 Binder 不能相互嵌套。

---

## ContentProviderBinder

提供查询应用程序信息的通用接口，将查询到的信息绑定到变量上。

| 属性 | 释义 |
|------|------|
| `uri` | 指定选用哪个 ContentProvider |
| `uriFormat` | 如果 uri 需要添加变量，可以用格式化，需要和 uriParas 一起使用 |
| `uriParas` | 同 Text element 的格式 |
| `columns` | 需要查询的列名，用逗号分隔 |
| `where` | 查询条件，同 SQL |
| `args` | where 的参数 |
| `order` | 排序条件，同 SQL |
| `countName` | 将查询结果数量绑定到该变量名 |
| `dependency` | 依赖关系，某个 Binder 查询结束后触发另一个 Binder 查询 |

### Variable 属性

| 属性 | 释义 |
|------|------|
| `name` | 变量名 |
| `type` | 数据类型：`string`/`double`/`float`/`int`/`long`/`blob.bitmap` |
| `column` | 变量绑定到的列的名称 |
| `row` | 变量绑定到的行数，默认为0 |

---

## 天气数据接口

```xml
<VariableBinders>
    <ContentProviderBinder name="weather"
        columns="temperature,description,weather_type,humidity,wind"
        countName="hasWeather"
        dependency="selected_city"
        uri="content://weather/actualWeatherData/1">
        <Variable name="weather_temperature" type="string" column="temperature"/>
        <Variable name="weather_description" type="string" column="description"/>
        <Variable name="weather_type" type="int" column="weather_type"/>
        <Variable name="weather_humidity" type="string" column="humidity"/>
    </ContentProviderBinder>
</VariableBinders>
```

### 天气接口返回字段

| ColIndex | 字段名 | 说明 | 类型 |
|---------|--------|------|------|
| 0 | `publish_time` | 实时天气信息发布时间（ms） | string |
| 1 | `city_id` | 城市唯一标识（经纬度） | string |
| 2 | `city_name` | 城市/街道名称 | string |
| 3 | `description` | 天气现象（实时） | string |
| 4 | `temperature` | 气温（实时） | string |
| 5 | `temperature_range` | 气温（预报） | string，支持数组 |
| 6 | `aqilevel` | AQI 等级 | int |
| 7 | `locale` | 语言 | string |
| 8 | `weather_type` | 天气类型（实时） | int/string |
| 9 | `humidity` | 湿度 | int（单位%） |
| 10 | `sunrise` | 日出时间（距0点毫秒数） | int |
| 11 | `sunset` | 日落时间（距0点毫秒数） | int |
| 12 | `wind` | 风向,风力 | string |
| 13 | `day` | 日期偏移量（0=昨天，1=今天，2=明天） | int |
| 14 | `pressure` | 气压（hPa） | int |
| 16 | `tmphighs` | 最高温（预报） | string，支持数组 |
| 17 | `tmplows` | 最低温（预报） | string，支持数组 |
| 18 | `forecast_type` | 天气类型（预报） | int/string |
| 19 | `weathernamesfrom` | 天气现象（预报） | string，支持数组 |
| 21 | `temperature_unit` | 气温单位（1=摄氏度，0=华氏度） | int |

### 天气现象代码对照表

| 代码 | 天气 | 代码 | 天气 | 代码 | 天气 |
|------|------|------|------|------|------|
| 0 | 晴 | 9 | 大雨 | 18 | 强沙尘暴 |
| 1 | 多云 | 10 | 中雨 | 19 | 沙尘暴 |
| 2 | 阴 | 11 | 小雨 | 20 | 沙尘 |
| 3 | 雾 | 12 | 雨夹雪 | 21 | 扬沙 |
| 4 | 特大暴雨 | 13 | 暴雪 | 22 | 冰雹 |
| 5 | 大暴雨 | 14 | 阵雪 | 23 | 浮尘 |
| 6 | 暴雨 | 15 | 大雪 | 24 | 霾 |
| 7 | 雷阵雨 | 16 | 中雪 | 25 | 冻雨 |
| 8 | 阵雨 | 17 | 小雪 | 99 | 无 |

### AQI 等级（中国大陆标准）

| 等级 | 范围 |
|------|------|
| 优 | 0 ~ 50 |
| 良 | 51 ~ 100 |
| 轻度污染 | 101 ~ 150 |
| 中度污染 | 151 ~ 200 |
| 重度污染 | 201 ~ 300 |
| 严重污染 | > 300 |

---

## 运动计步（MIUI12新增）

```xml
<VariableBinders>
    <ContentProviderBinder name="step" uri="content://com.xiaomi.fitness/step" columns="steps,goal,distance,energy,strength_duration,summary" countName="hasStep">
        <Variable name="step_steps" type="string" column="steps"/>
        <Variable name="step_goal" type="string" column="goal"/>
        <Variable name="step_distance" type="string" column="distance"/>
        <Variable name="step_energy" type="string" column="energy"/>
    </ContentProviderBinder>
</VariableBinders>
```

| 字段名 | 说明 | 单位 |
|--------|------|------|
| `steps` | 步数 | 步 |
| `goal` | 目标步数 | 步 |
| `distance` | 距离 | 公里 km |
| `energy` | 消耗卡路里 | 千卡 kcal |
| `strength_duration` | 运动中高强度时长 | 分钟 |
| `summary` | 运动是否达标：0=暂无，1=尚未达标，2=运动不足，3=运动达标 | - |

---

## 作息数据（MIUI13新增）

```xml
<ContentProviderBinder name="bedtime" uri="content://com.android.deskclock.bedtimeProvider/bedtime" columns="bedtime_state,sleep_hour,sleep_minute,wake_hour,wake_minute,repeat_type" countName="hasBedtime">
    <Variable name="bedtime_state" type="int" column="bedtime_state"/>
    <Variable name="sleep_hour" type="int" column="sleep_hour"/>
    <Variable name="wake_hour" type="int" column="wake_hour"/>
</ContentProviderBinder>
```

| 字段名 | 说明 |
|--------|------|
| `bedtime_state` | 作息管理设置状态：0=关闭，1=开启 |
| `sleep_hour` | 入睡时间的小时（24小时制） |
| `sleep_minute` | 入睡时间的分 |
| `wake_hour` | 起床时间的小时（24小时制） |
| `wake_minute` | 起床时间的分 |
| `repeat_type` | 重复周期：127=每天，-1=法定工作日，31=周一至周五 |

---

## 闹钟数据（MIUI13新增）

```xml
<ContentProviderBinder name="alarm" uri="content://com.android.deskclock/alarm" columns="message,enabled,hour,minutes,alarmtime,daysofweek" countName="hasAlarm">
    <Variable name="alarm_hour" type="string[]" column="hour"/>
    <Variable name="alarm_minutes" type="string[]" column="minutes"/>
    <Variable name="alarm_enabled" type="string[]" column="enabled"/>
</ContentProviderBinder>
```

| 字段名 | 说明 |
|--------|------|
| `message` | 备注 |
| `enabled` | 开关 |
| `hour` | 时 |
| `minutes` | 分 |
| `alarmtime` | 响铃时间 |
| `daysofweek` | 重复方式：0=一次性，1=周一，2=周二，4=周三，8=周四，16=周五，32=周六，64=周日，128=法定工作日，256=法定节假日 |

---

## 日程数据

```xml
<ContentProviderBinder name="calendar" uri="content://com.android.calendar/events" columns="title,eventLocation,dtstart,dtend,allDay" countName="hasCalendar">
    <Variable name="cal_title" type="string[]" column="title"/>
    <Variable name="cal_location" type="string[]" column="eventLocation"/>
    <Variable name="cal_start" type="string[]" column="dtstart"/>
</ContentProviderBinder>
```

---

## 传感器（SensorBinder）

### 重力传感器

```xml
<SensorBinder type="gravity" rate="1">
    <Variable name="gravity_x" index="0"/>
    <Variable name="gravity_y" index="1"/>
    <Variable name="gravity_z" index="2"/>
</SensorBinder>
```

| index | 释义 |
|-------|------|
| 0 | x 方向的重力加速度 |
| 1 | y 方向的重力加速度 |
| 2 | z 方向的重力加速度 |

rate 常量（单位微秒）：0=0微秒，1=20000微秒，2=66667微秒，3=200000微秒（默认）。值越小刷新越高，也会相对耗电。

### 方向传感器

```xml
<SensorBinder type="orientation" rate="1">
    <Variable name="azimuth" index="0"/>
    <Variable name="pitch" index="1"/>
    <Variable name="roll" index="2"/>
</SensorBinder>
```

| index | 释义 |
|-------|------|
| 0 | 方位角，0~359（0=北，90=东，180=南，270=西） |
| 1 | 俯仰角，-180~180，z轴转向y轴为正方向 |
| 2 | 滚转角，-90~90，x轴转向z轴为正方向 |

### 加速度传感器

```xml
<SensorBinder type="accelerometer" rate="1">
    <Variable name="acc_x" index="0"/>
    <Variable name="acc_y" index="1"/>
    <Variable name="acc_z" index="2"/>
</SensorBinder>
```

### 线性加速度传感器

线性加速度 = 加速度 - 重力加速度

```xml
<SensorBinder type="linear_acceleration" rate="1">
    <Variable name="linear_x" index="0"/>
    <Variable name="linear_y" index="1"/>
    <Variable name="linear_z" index="2"/>
</SensorBinder>
```

### 气压传感器

```xml
<SensorBinder type="pressure" rate="3">
    <Variable name="pressure_val" index="0"/>
</SensorBinder>
```

| index | 释义 |
|-------|------|
| 0 | 气压值（hPa），海平面平均气压约1013.25hPa |

> 注意：仅支持压力传感器的设备可以获取到值。
