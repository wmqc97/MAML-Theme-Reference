# 05 - 内置函数与 JSON

[返回目录](00-index.md)

## 内置函数

| 函数                                         | 用途                          |
| -------------------------------------------- | ----------------------------- |
| sin(x)                                       | 角度 x 的正弦（弧度）         |
| cos(x)                                       | 角度 x 的余弦                 |
| tan(x)                                       | 角度 x 的正切                 |
| asin(x)                                      | 反正弦（-π/2 到 π/2）         |
| acos(x)                                      | 反余弦（0 到 π）              |
| atan(x)                                      | 反正切（-π/2 到 π/2）         |
| sinh(x)                                      | 双曲正弦                      |
| cosh(x)                                      | 双曲余弦                      |
| sqrt(x)                                      | 平方根                        |
| abs(x)                                       | 绝对值                        |
| min(x,y)                                     | 最小值                        |
| max(x,y)                                     | 最大值                        |
| pow(x,y)                                     | x 的 y 次幂                   |
| len(number)                                  | 数字位数                      |
| digit(number, position)                      | 提取指定位置的数字            |
| substr(string, start, length)                | 提取子串                      |
| strIsEmpty(string)                           | 检查是否为空（1=空）          |
| isnull(number)                               | 检查是否为 null（1=null）     |
| ceil()                                       | 向上取整                      |
| int()                                        | 向下取整（地板除）            |
| round()                                      | 四舍五入                      |
| rand()                                       | 随机 0-1                      |
| formatDate('format',#time_sys)               | 日期转字符串                  |
| strStartsWith(str,prefix)                    | 检查字符串开头                |
| strEndsWith(str,suffix)                      | 检查字符串结尾                |
| strIndexOf(@str,substr)                      | 首次出现位置                  |
| strLastIndexOf(@str,substr)                  | 最后出现位置                  |
| strContains(@str,substr)                     | 包含检查                      |
| strReplaceAll(@str,old,new)                  | 替换所有匹配                  |
| preciseeval('@expr',3)                       | 带精度的表达式求值            |
| eval('expr')                                 | 求值字符串表达式              |
| formatFloat('%.3f',#num)                     | 浮点数格式化为字符串          |
| strMatches(@str,'pattern')                   | 正则匹配                      |
| strTrim(' str ')                             | 去除空白                      |
| strReplaceFirst(str,old,new)                 | 替换首次匹配                  |
| strToLowerCase(str)                          | 转小写                        |
| strToUpperCase(str)                          | 转大写                        |
| diffDate(target_ms, current_ms, repeat_type) | 日期间隔天数。**MIUI14 新增** |

---

## JSON 数据支持

**MIUI14 新增，仅限小部件使用。**

| 函数                                     | 说明                   |
| ---------------------------------------- | ---------------------- |
| jsonGetString(JSONObject, String)        | 按键获取字符串值       |
| jsonGetBoolean(JSONObject, String)       | 按键获取布尔值         |
| jsonGetInt(JSONObject, String)           | 按键获取整数值         |
| jsonGetObject(JSONObject, String)        | 按键获取 JSON 对象     |
| jsonGetArray(JSONObject, String)         | 按键获取 JSON 数组     |
| jsonArrayGetIndex(JSONArray, int)        | 获取数组索引处的对象   |
| newJsonObject()                          | 创建空 JSON 对象       |
| newJsonArray()                           | 创建空 JSON 数组       |
| getJsonArrayLength(JSONArray)            | 获取数组长度           |
| jsonObjectEquals(JSONObject, JSONObject) | 比较对象（1=相等）     |
| strToJson(String)                        | 解析字符串为 JSON 对象 |
| jsonToStr(JSONObject)                    | 转换 JSON 为字符串     |
| isJsonObject(Object)                     | 检查是否为 JSON 对象   |
| isJsonArray(Object)                      | 检查是否为 JSON 数组   |

示例：

```xml
<Var name="json_data" expression="'{"img_path": [{ "path": "Sep/img.png" }]}'" type="string" />
<Button x="0" y="0" w="#view_width" h="#view_height">
    <Triggers>
        <Trigger action="up">
            <VariableCommand name="dataToJson" expression="strToJson(@json_data)" type="jsonO" />
            <VariableCommand name="data" type="jsonA" expression="jsonGetArray($dataToJson,'img_path')" />
            <VariableCommand name="imgPathLength" type="number" expression="getJsonArrayLength($$data)" />
            <VariableCommand name="img_path_str" type="string" expression="jsonGetString(jsonArrayGetIndex($$data, 0), 'path')" />
        </Trigger>
    </Triggers>
</Button>
```
