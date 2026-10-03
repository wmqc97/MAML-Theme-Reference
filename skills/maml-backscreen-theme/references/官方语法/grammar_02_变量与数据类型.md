# 变量与数据类型

> 来源：https://zhuti.designer.xiaomi.com/docs/grammar/

---

## 数据类型

| 类型 | 释义 |
|------|------|
| `int` | 整数，如 -2、0、1、100 |
| `number` | 数字，包括整数和浮点数 |
| `number[]` | 数字数组 |
| `string` | 字符串，如 "hello"、"world" |
| `string[]` | 字符串数组 |
| `boolean` | 布尔值，true 或 false |
| `float` | 浮点数 |
| `float[]` | 浮点数组 |
| `jsonO` | JSON 对象（MIUI14新增） |

---

## 常规变量（Var）

| 属性 | 类型 | 释义 |
|------|------|------|
| `name` | string | 自定义变量名 |
| `expression` | number/string | 变量对应的表达式或常量。字符串常量需要多一套单引号，如 `expression="'我是文字'"` |
| `type` | string | 定义变量类型，默认 number |
| `const` | boolean | true 时变量初始化后不会重新计算，但可以用命令重新赋值。合理使用可提高运行效率 |
| `persist` | boolean | 变量持久化。true 时值会一直保存，无论解锁后重新锁定或重新应用主题都不会还原；默认 false |
| `threshold` | number | 阈值触发，当变量值的变化超过设定阈值时，触发 Trigger |

### 变量声明示例

```xml
<!-- 数字类型 -->
<Var name="a" expression="200" />
<Var name="b" expression="#a + 100" type="number"/>
<Var name="c" expression="2" type="int"/>
<Var name="d" expression="2.56" type="float"/>

<!-- 字符串类型 -->
<Var name="e" expression="'永远相信美好的事情即将发生'" type="string"/>

<!-- const 变量（初始化后不自动重算） -->
<Var name="f" expression="100" const="true"/>

<!-- 持久化变量 -->
<Var name="g" expression="0" persist="true"/>
```

---

## 数组变量

在类型中加 `[]` 声明数组：`type="number[]"` 或 `type="string[]"`

```xml
<!-- 数字数组 -->
<Var name="numVar" values="100,200,300,400,500" type="number[]"/>

<!-- 字符串数组 -->
<Var name="strVar" values="'水瓶座','双鱼座','白羊座'" type="string[]"/>

<!-- 固定长度数组 -->
<Var name="h" size="3" const="true" type="number[]"/>
<Var name="h" expression="40" type="number[]" index="0" const="true"/>
<Var name="h" expression="50" type="number[]" index="1" const="true"/>
<Var name="h" expression="60" type="number[]" index="2" const="true"/>
```

### 数组引用

通过 `name[索引]` 获取数组中的值，索引从 0 开始：

```xml
<!-- #numVar[2] 的值是 300 -->
<Text x="100" y="100" color="#ffffff" size="50" textExp="#numVar[2]"/>

<!-- @strVar[0] 的值是 水瓶座 -->
<Text x="100" y="200" color="#ffffff" size="50" textExp="@strVar[0]"/>
```

---

## 变量引用规则

- 数字类型变量用 `#变量名` 引用
- 字符串类型变量用 `@变量名` 引用
- 数组元素用 `#变量名[索引]` 或 `@变量名[索引]` 引用

```xml
<Text textExp="#num"/>          <!-- 数字变量 -->
<Text textExp="@str"/>          <!-- 字符串变量 -->
<Text textExp="#numArr[1]"/>    <!-- 数字数组元素 -->
<Text textExp="@strArr[0]"/>    <!-- 字符串数组元素 -->
```

---

## 变量修改（VariableCommand）

通过 `VariableCommand` 命令修改变量，**必须放在 Trigger 中触发**：

```xml
<Trigger>
    <!-- 修改普通变量 -->
    <VariableCommand name="a" expression="300"/>
    <!-- 修改数组元素 -->
    <VariableCommand name="b" expression="500" index="1" type="number[]"/>
    <!-- 带条件的修改 -->
    <VariableCommand name="count" expression="#count+1" condition="#count{100"/>
    <!-- 带延迟的修改 -->
    <VariableCommand name="x" expression="0" delay="500"/>
</Trigger>
```

| 属性 | 释义 |
|------|------|
| `name` | 变量名 |
| `expression` | 赋值表达式 |
| `condition` | 条件判断，为真时执行，为假时不执行 |
| `delay` | 延迟执行，单位毫秒 |
| `delayCondition` | 延时判断，在 delay 时间之后再进行判断 |

---

## 小部件持久化变量

**OS新增，请在小部件中使用**

小部件持久化变量在小部件被移除后仍然保留，重新添加时可以恢复之前的值。

```xml
<Var name="myPersistVar" expression="0" persist="true"/>
```
