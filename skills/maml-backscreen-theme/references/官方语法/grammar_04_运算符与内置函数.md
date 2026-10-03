# 运算符与内置函数

> 来源：https://zhuti.designer.xiaomi.com/docs/grammar/

---

## 运算符

| 操作符 | 优先级 | 释义 |
|--------|--------|------|
| `+` | 4 | 加（也可拼接字符串：`'qwe'+'asd'` = `'qweasd'`） |
| `-` | 4 | 减 |
| `*` | 3 | 乘以 |
| `/` | 3 | 除以 |
| `%` | 3 | 取模（不是百分比） |
| `^` | 10 | 按位异或 |
| `~` | 2 | 按位取反 |
| `{{` | 5 | 左移位 |
| `}}` | 5 | 右移位 |
| `!` | 2 | 逻辑非 |
| `==` | 7 | 等于 |
| `!=` | 7 | 不等于 |
| `**` | 11 | 逻辑与（相当于 &&） |
| `\|\|` | 12 | 逻辑或 |
| `}` | 6 | 大于（相当于 >） |
| `}=` | 6 | 大于等于（相当于 >=） |
| `{` | 6 | 小于（相当于 <） |
| `{=` | 6 | 小于等于（相当于 <=） |

---

## 条件判断函数（旧式，仍支持）

| 函数 | 释义 |
|------|------|
| `eq(x, y)` | x==y，结果为1，否则为0 |
| `ne(x, y)` | x!=y，结果为1，否则为0 |
| `ge(x, y)` | x>=y，结果为1，否则为0 |
| `gt(x, y)` | x>y，结果为1，否则为0 |
| `le(x, y)` | x<=y，结果为1，否则为0 |
| `lt(x, y)` | x<y，结果为1，否则为0 |
| `not(x)` | 逻辑非；x=0时结果为1，x=1时结果为0 |
| `ifelse(x, y, z)` | x>0时结果为y，否则为z |
| `ifelse(x1,y1,x2,y2,...,z)` | 多条件判断，依次检测，最后取z |
| `eqs(@str1, @str2)` | 字符串比较，相等返回1，否则返回0 |

### ifelse 示例

```xml
<!-- 深色模式下显示白色，否则显示黑色 -->
<Text color="ifelse(#__darkmode==1,'#ffffff','#000000')" .../>

<!-- 多条件 -->
<Text textExp="ifelse(#hour24{6,'凌晨',ifelse(#hour24{12,'上午',ifelse(#hour24{18,'下午','晚上')))"/>
```

---

## 数学函数

| 函数 | 作用 |
|------|------|
| `sin(x)` | 正弦值（弧度制） |
| `cos(x)` | 余弦值（弧度制） |
| `tan(x)` | 正切值（弧度制） |
| `asin(x)` | 反正弦值，结果在 -π/2 到 π/2 |
| `acos(x)` | 反余弦值，结果在 0 到 π |
| `atan(x)` | 反正切值，结果在 -π/2 到 π/2 |
| `sinh(x)` | 双曲正弦值 |
| `cosh(x)` | 双曲余弦值 |
| `sqrt(x)` | 平方根 |
| `abs(x)` | 绝对值 |
| `min(x, y)` | 较小值 |
| `max(x, y)` | 较大值 |
| `pow(x, y)` | x 的 y 次幂 |
| `ceil(x)` | 向上取整（6.1 → 7） |
| `int(x)` | 向下取整（6.9 → 6） |
| `round(x)` | 四舍五入取整 |
| `rand()` | 0到1之间的随机数；`rand()*100` 生成0-100随机数 |

---

## 字符串函数

| 函数 | 作用 |
|------|------|
| `len(x)` | 获取变量和字符串位数 |
| `digit(数字, 第几位)` | 取给定数字的第几位，如 `digit(12345, 2) = 4`（下标从右向左，从1开始，原数字不超过10位） |
| `substr(原字符串, 开始位置, 长度)` | 截取子串，如 `substr('今天真热啊',1,2) = '天真'`（位置从0开始） |
| `strIsEmpty(@str)` | 字符串是否为空，空返回1，非空返回0 |
| `isnull(#num)` | 数字变量是否为空，空返回1，非空返回0 |
| `formatDate('HH:mm', #time_sys)` | 日期格式化成字符串 |
| `strStartsWith('123456789','12')` | 是否以某字符串开头，是返回1 |
| `strEndsWith('123456789','89')` | 是否以某字符串结束，是返回1 |
| `strIndexOf(@str_a,'str_b')` | str_b 第一次出现在 str_a 中的位置 |
| `strLastIndexOf(@str_a,'str_b')` | str_b 最后出现在 str_a 中的位置 |
| `strContains(@str_a,'str_b')` | str_a 是否包含 str_b，包含返回1 |
| `strReplaceAll(@str_a,'str_b','str_c')` | 用 str_c 替换 str_a 中所有的 str_b，支持正则 |
| `strReplaceFirst('ABCdefABC','ABC','666')` | 替换第一个匹配项，结果 `666defABC` |
| `strToLowerCase('ABCdef')` | 转换成小写，结果 `abcdef` |
| `strToUpperCase('ABCdef')` | 转换成大写，结果 `ABCDEF` |
| `strTrim(' 123 ')` | 裁切开头和尾部的空格、制表、回车符 |
| `strMatches(@str,'.*[\+*/-]$')` | 正则表达式匹配 |
| `preciseeval('@str_a', 3)` | 计算字符串的值，精确到小数点后3位，如 `preciseeval('5*5+0.333',3)==25.333` |
| `eval('1+2')` | 计算字符串的值（注意浮点数精度问题） |
| `formatFloat('%.3f', #num)` | 格式化小数点后几位并转换成字符串（会占位，如3.000） |

---

## 日期差值函数（MIUI14新增，小部件使用）

```
diffDate(目标时间ms, 当前时间ms, 重复类型)
```

计算目标时间和当前时间差了多少天。

| 重复类型 | 说明 |
|---------|------|
| 0 | 不重复（默认） |
| 1 | 年 |
| 2 | 月 |
| 3 | 周 |

---

## JSON 数据处理函数（MIUI14新增，小部件使用）

| 函数 | 描述 |
|------|------|
| `jsonGetString(JSONObject, String)` | 返回指定键的字符串值 |
| `jsonGetBoolean(JSONObject, String)` | 返回指定键的布尔值（1或0） |
| `jsonGetInt(JSONObject, String)` | 返回指定键的整数值 |
| `jsonGetObject(JSONObject, String)` | 返回指定键的 JSON 对象 |
| `jsonGetArray(JSONObject, String)` | 返回指定键的 JSON 数组 |
| `jsonArrayGetIndex(JSONArray, int)` | 返回 JSON 数组中指定索引位置的 JSON 对象 |
| `newJsonObject()` | 创建一个新的空 JSON 对象 |
| `newJsonArray()` | 创建一个新的空 JSON 数组 |
| `getJsonArrayLength(JSONArray)` | 返回 JSON 数组的长度 |
| `jsonObjectEquals(JSONObject, JSONObject)` | 两个 JSON 对象相等返回1，否则返回0 |
| `strToJson(String)` | 将字符串解析为 JSON 对象 |
| `jsonToStr(JSONObject)` | 将 JSON 对象转换为字符串 |
| `isJsonObject(Object)` | 是 JSON 对象返回1，否则返回0 |
| `isJsonArray(Object)` | 是 JSON 数组返回1，否则返回0 |

### JSON 使用示例

```xml
<VariableBinders>
    <ContentProviderBinder name="a" uri="content://xxxx" columns="XXX" countName="hasData">
        <Variable name="str" type="string" column="XXX"/>
        <Trigger>
            <!-- 将 JSON 字符串解析为 jsonO 对象 -->
            <VariableCommand name="data" expression="strToJson(@str)" type="jsonO"/>
        </Trigger>
    </ContentProviderBinder>
</VariableBinders>

<!-- 从 JSON 对象中取值 -->
<Text textExp="jsonGetString($data,'name')"/>
<Text textExp="#jsonGetInt($data,'age')"/>
```
