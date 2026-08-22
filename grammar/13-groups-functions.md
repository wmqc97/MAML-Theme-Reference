# 13 - 组与函数
[返回目录](00-index.md)

## Group 元素

组织多个子元素，支持裁剪与分层。

```xml
<Group x="0" y="0" clip="true">
    <!-- 子元素超出 Group 范围会被裁剪 -->
</Group>
```

- `clip`：裁剪超出区域
- `layered`：分层渲染

## Triggers 触发器

按钮控制触发内容显示/隐藏。

```xml
<Triggers>
    <Trigger action="down">
        <!-- 按下时显示 -->
    </Trigger>
    <Trigger action="up">
        <!-- 松开时显示 -->
    </Trigger>
</Triggers>
```

## Function 自定义函数

MIUI12+ 支持，通过 `FunctionCommand` 调用。

```xml
<Function name="myFunc">
    <VariableCommand name="result" value="42" />
</Function>
```

调用：

```xml
<FunctionCommand command="myFunc" />
```

## 嵌套 IfCommand

```xml
<VariableCommand name="score" value="85" />
<IfCommand expression="#score >= 90">
    <Text x="0" y="0" color="0xffff0000" text="优秀" />
</IfCommand>
<IfCommand expression="#score >= 60">
    <Text x="0" y="0" color="0xff00ff00" text="及格" />
</IfCommand>
```

可配合 `GraphicsCommand` 绘制路径或矩形填充。
