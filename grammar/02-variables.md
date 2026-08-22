# 02 - 变量

[返回目录](00-index.md)

变量在运行时可被改变。字符串变量使用 `@` 引用，数值变量使用 `#` 引用（如 `@string`、`#number`）。

## 数据类型

| 类型     | 说明                          |
| -------- | ----------------------------- |
| int      | 整数值，如 -2、0、1、100      |
| number   | 数值，包括整数和浮点数        |
| number[] | 数字数组                      |
| string   | 字符序列，如 "hello"、"world" |
| string[] | 字符串数组                    |
| boolean  | true 或 false                 |
| float    | 浮点数                        |
| float[]  | 浮点数组                      |

## 常规变量

```xml
<!-- 变量以 Var 开始 -->
<Var name="" expression="" type="" const="" threshold=""/>
```

| 属性       | 类型          | 可用表达式/变量 | 说明                                                                  |
| ---------- | ------------- | --------------- | --------------------------------------------------------------------- |
| name       | string        | x/x             | 自定义变量名                                                          |
| expression | number/string | o/o             | 表达式或常量。字符串常量需加额外单引号：`expression="'text'"`         |
| type       | 各类型        | x/x             | 数据类型。默认：number                                                |
| const      | boolean       | x/x             | 若为 true，变量在初始化后不再重新计算，但可通过命令重新赋值。提高效率 |
| persist    | boolean       | x/x             | 变量持久化。若为 true，值在解锁和主题重新应用后保持不变。默认 false   |
| threshold  | number        | x/x             | 阈值触发。当值变化超过阈值时触发命令                                  |

## 数组变量

在 type 后加 `[]` 声明数组：`type="number[]"` 或 `type="string[]"`。

```xml
<!-- 数字类型 -->
<Var name="numVar" type="number[]" const="true" expression="" values="100,150,500,550,800,850"/>
<!-- 文本类型；必须加上 expression="''" 属性 -->
<Var name="strVar" type="string[]" const="true" expression="''" values="'Aquarius','Pisces','Aries','Taurus'"/>
```

通过 `name[index]` 访问，如 `#numVar[2]` = 500，`@strVar[0]` = "Aquarius"。索引从 0 开始。

## 小部件持久化变量

（系统新增，仅限小部件使用）

```xml
<Permanence name="a_number" expression="9999" type="number"/>
<Permanence name="a_string" expression="'九九九九'" type="string"/>
<!-- 修改变量 -->
<PermanenceCommand name="a_number" expression="1111" requestUpdate="true" type="number" />
<PermanenceCommand name="a_string" expression="'一一一一'" requestUpdate="true" type="string" />
```
