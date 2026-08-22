# 17 - 外部数据
[返回目录](00-index.md)

## 通知

| 变量 | 说明 |
|------|------|
| `#sms_unread_count` | 未读短信数 |
| `#call_missed_count` | 未接来电数 |

## 天气 WeatherInfo

需先配置 WeatherInfo 元素获取天气数据。

```xml
<WeatherInfo city="北京" />
```

### 天气变量

| 变量 | 说明 |
|------|------|
| `#weather_id` | 天气 ID |
| `#weather_temperature` | 当前温度 |
| `@weather_city` | 城市名 |
| `@weather_wind_description` | 风力描述 |
| `@weather_description` | 天气描述 |
| `#weather_high` | 最高温度 |
| `#weather_low` | 最低温度 |
| `#weather_humidity` | 湿度 |
| `#weather_uv` | 紫外线指数 |
| `#weather_visibility` | 能见度 |
| `#weather_aqi` | 空气质量指数 |

## 运动计步

```xml
<ExternCommand command="requestSportStep" />
```

变量：`#sport_step_count`、`#sport_step_target`、`#sport_step_distance`。

## 语音转文字

MIUI14 限定（小部件），变量：`#voice_text`。

## 作息状态

变量：`#rest_status`。

## 闹钟

变量：`@next_alarm_time`（下次闹钟时间）。

## 日程

| 变量 | 说明 |
|------|------|
| `#next_date_schedule_title` | 下个日程标题 |
| `#next_date_schedule_time` | 下个日程时间 |
| `#next_date_schedule_location` | 下个日程地点 |
