# 06 - 阈值

[返回目录](00-index.md)

阈值充当边界，当值跨越边界时触发事件。

```xml
<!-- 当 #number 变化 1 时，执行 Trigger 命令 -->
<Var name="time3" expression="#number" threshold="1">
     <Trigger>
        ...
     </Trigger>
</Var>

<!-- 当字符串 @string 变化时，执行 Trigger 命令 -->
<Var name="time3" expression="@string" >
     <Trigger>
        ...
     </Trigger>
</Var>
```
