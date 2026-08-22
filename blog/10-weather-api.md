# 小米天气新接口

> 来源：https://zhuti.designer.xiaomi.com/docs/blog/weatherApi.html

## 概述

本 API 提供定位城市/街道 5 天（不含昨天）的天气查询服务，支持条件查询。用户可在天气客户端取消关注定位城市/街道，此时返回第一个已关注城市的天气数据。

## 数据更新策略

API 基于三种情况运行：

1. 本地 + 网络
2. 仅本地数据
3. 仅网络数据

本地数据按后台数据更新任务每小时更新一次。

## API URI 与参数

**URI 格式：** `content://weather/actualWeatherData/{dataType}/{wantOnlyCityName}`

| 参数                     | 值  | 说明                                  | 备注                   |
| ------------------------ | --- | ------------------------------------- | ---------------------- |
| dataType（必填）         | 1   | 检查本地数据，超过 1 小时则刷新后返回 | 默认逻辑，必须异步调用 |
| dataType                 | 2   | 直接获取本地数据                      | 可同步调用，建议异步   |
| dataType                 | 3   | 直接获取网络数据                      | 必须异步调用           |
| wantOnlyCityName（可选） | 1/0 | 是否仅需要城市名（vs 街道级别）       | 默认 0，返回精确名称   |

> 为降低功耗，如无特殊需求，请尽量使用 type 1。

## 完整字段参考

| 索引 | 字段名            | 说明                       | 类型       | 示例           |
| ---- | ----------------- | -------------------------- | ---------- | -------------- |
| 0    | publish_time      | 实时天气发布时间（时间戳） | string     | 1508143200000  |
| 1    | city_id           | 城市唯一标识               | string     | 39.959_116.298 |
| 2    | city_name         | 城市/街道名称              | string     | 安宁庄南路     |
| 3    | description       | 天气现象（实时）           | string     | 多云           |
| 4    | temperature       | 温度（实时）               | string     | 18℃            |
| 5    | temperature_range | 温度（预报）               | string     | 8℃~18℃         |
| 6    | aqilevel          | AQI 等级                   | int        | 90             |
| 7    | locale            | 语言                       | string     | zh_CN          |
| 8    | weather_type      | 天气类型（实时）           | int/string | 1              |
| 9    | humidity          | 湿度                       | int        | 68%            |
| 10   | sunrise           | 日出时间                   | int        | 80760000       |
| 11   | sunset            | 日落时间                   | int        | 34440000       |
| 12   | wind              | 风向和风力                 | string     | 东南风,2级     |
| 13   | day               | 日期偏移                   | int        | 1              |
| 14   | pressure          | 大气压                     | int        | 1016hPa        |
| 15   | timestamp         | 预报天气发布时间           | string     | 1508055000000  |
| 16   | tmphighs          | 最高温度（预报）           | string     | 18             |
| 17   | tmplows           | 最低温度（预报）           | string     | 8              |
| 18   | forecast_type     | 天气类型（预报）           | int/string | 1              |
| 19   | weathernamesfrom  | 天气现象（预报）           | string     | 多云           |
| 20   | weathernamesto    | 同上                       | string     | -              |
| 21   | temperature_unit  | 温度单位                   | int        | 1              |
| 22   | water             | 当前未使用（降水概率）     | -          | 50%            |

## 完整 XML 代码示例

```xml
<VariableBinders>
    <ContentProviderBinder name="WeatherProvider" uri="content://weather/actualWeatherData/1" columns="city_id,city_name,weather_type,aqilevel,description,temperature,forecast_type,tmphighs,tmplows,wind,humidity,sunrise,sunset,pressure,weathernamesfrom,forecast_type,publish_time" countName="hasweather">
        <Variable name="weather_city_id" type="string" column="city_id"/>
        <Variable name="weather_location" type="string" column="city_name"/>
        <Variable name="weather_id" type="int" column="weather_type"/>
        <Variable name="weather_temperature" type="int" column="temperature"/>
        <Variable name="weather_aqi" type="int" column="aqilevel"/>
        <Variable name="weather_sunrise" type="int" column="sunrise"/>
        <Variable name="weather_sunset" type="int" column="sunset"/>
        <Variable name="weather_forecast_type" type="int" column="forecast_type"/>
        <Variable name="weather_wind" type="string" column="wind"/>
        <Variable name="weather_pressure" type="int" column="pressure"/>
        <Variable name="weather_humidity" type="int" column="humidity"/>
        <Variable name="weather_type" type="string[]" column="weather_type"/>
        <Variable name="weather_description" type="string[]" column="description"/>
        <Variable name="weather_weathernamesfrom" type="string[]" column="weathernamesfrom"/>
        <Variable name="weather_temphigh" type="string[]" column="tmphighs"/>
        <Variable name="weather_templow" type="string[]" column="tmplows"/>
        <Variable name="weather_publish_time" type="string" column="publish_time"/>
    </ContentProviderBinder>
</VariableBinders>

<Text x="100" y="300" size="40" color="#ffffff" textExp="#weather_temperature"/>

<Array count="5" indexName="__weather">
    <Text x="100" y="500+50*#__weather" size="40" color="#ffffff" textExp="#weather_forecast_type[#__weather]"/>
</Array>
```

## 简化天气图标使用

创建 26 个独立天气图标工作量较大，可按天气类型分类合并图标。

### 简化代码示例

```xml
<VariableBinders>
    <ContentProviderBinder name="WeatherProvider" uri="content://weather/actualWeatherData/1" columns="city_name,weather_type,aqilevel,description,temperature,temperature_range" countName="hasweather">
        <Variable name="weather_location" type="string" column="city_name"/>
        <Variable name="weather_id" type="int" column="weather_type"/>
        <Variable name="weather_temperature" type="string" column="temperature"/>
        <Variable name="weather_description" type="string" column="description"/>
        <Variable name="weather_aqi" type="int" column="aqilevel"/>
        <Trigger>
            <!-- 空气质量 -->
            <VariableCommand name="air_quality" expression="ifelse(#weather_aqi}0**#weather_aqi{=50,'空气优',#weather_aqi}50**#weather_aqi{=100,'空气良好',#weather_aqi}100**#weather_aqi{=150,'轻度污染',#weather_aqi}150**#weather_aqi{=200,'中度污染',#weather_aqi}200**#weather_aqi{=300,'严重污染',#weather_aqi}300,'重度污染','获取信息异常')" type="string"/>
            <!-- 天气类型简化版；可用于天气图标展示。例如：srcid="#weatherId" -->
            <VariableCommand name="weatherId" expression="ifelse(#weather_id}25||#weather_id{0,0,(#weather_id}=4**#weather_id{=6||#weather_id}=8**#weather_id{=11||#weather_id==25),4,#weather_id}=13**#weather_id{=17,13,#weather_id}=18**#weather_id{=21||#weather_id==23,18,#weather_id)"/>
        </Trigger>
    </ContentProviderBinder>
</VariableBinders>

<!-- 用图展示天气现象 -->
<Image x="100" y="100" src="weather.png" srcid="#weatherId"/>
```

---

_最近更新时间：2020/12/30_
