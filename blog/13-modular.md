# 封装自己的插件模块

> 来源：https://zhuti.designer.xiaomi.com/docs/blog/modular.html

## 一、插件的概念

### 1. 背景

原生 MAML 所有代码都写在 manifest.xml 一个文件中，无模块化封装的概念，对于大型项目代码可读性可维护性都较差。主题编辑器 2.0 时引入了插件 1.0 系统，通过封装 MAML 代码为一个个插件，结合编辑器点击的交互操作，可以将不同插件内部的逻辑以搭积木的方式最终编译到 manifest.xml 文件中，并生成原生 MAML 可识别的代码。主题编辑器 3.0 需要对插件进行更符合设计师交互行为的可视化操作，因此开发了新的 MAML 插件 2.0 系统。

### 2. 编辑器的插件系统定义

- 是原生 MAML 的超集
- 支持 lockscreen、miwallpaper、clock_2x4 等编辑器支持的百变框架的模块
- 主文件是和 manifest.xml 同级的 main.xml，最终会编译成 manifest.xml
- 拓展的语法在经过编辑器编译成 manifest.xml 之前并不能直接被手机识别
- 可以对 MAML 模块的组件进行更高级的封装，能更清晰地组织代码的逻辑及复用组件

## 二、基本语法及使用

### 1. 插件的声明

```xml
<?xml version="1.0" encoding="utf-8"?>
<Template>
    <Props>
        <item name="x" default="100" type="number" description="x坐标"/>
        <item name="y" default="200" type="number" description="y坐标"/>
        <item name="text" default="hello world" type="string" description="文字内容"/>
        <item name="imgSrc" default="a.png" type="bitmap" description="示例图片"/>
        <item name="alpha" default="255" type="number" description="图片透明度"/>
    </Props>
    <Text x="$x" y="$y" color="#ffffff" size="30" text="$text"/>
    <Image y="800" src="$imgSrc" alpha="$alpha" />
</Template>
```

定义一个 Props 标签，用于接收外部参数。Props 标签内的 item 每条数据设定 default 默认值。Props 标签中定义的数据通过 `$` 符号绑定到元素对象中。type 与 description 为编辑器交互字段，编辑器通过不同 type 在界面展示不同输入样式（如 number 对应输入框，color 对应颜色选择器）。Props 非必须，看需求决定。

### 2. 插件的使用

假设插件放置在 modules 目录下的 plugin1.xml 中：

```xml
<?xml version="1.0" encoding="utf-8"?>
<Lockscreen version="1" frameRate="60" compiler="true">
    <Plugin name="hello" src="modules/plugin1" y="500" text="foo" />
</Lockscreen>
```

编译后生成：

```xml
<?xml version="1.0" encoding="utf-8"?>
<Lockscreen version="1" frameRate="60">
    <Group name="hello">
        <Text x="100" y="500" color="#ffffff" size="30" text="foo"/>
        <Image y="800" src="a.png" alpha="255" />
    </Group>
</Lockscreen>
```

除 y 和 text 为调用插件传入的值外，其余属性均为默认值。插件内定义的代码被包裹在一个 Group 中，方便后续整体操作。

## 三、作用域

原生 MAML 所有变量都是全局变量，无作用域的概念。插件 2.0 系统将作用域限定为单个插件，实现方式为插件内所有元素在编译后在原有 name 后统一加 6 位随机字符以私有化该对象。

```xml
<!-- 编译前 -->
<Var name="text_x" expression="300"/>
<Text name="text" x="#text_x" y="$y" color="#ffffff" size="30" text="foo"/>

<!-- 编译后 -->
<Var name="text_x_48utrd" expression="300"/>
<Text name="text_48utrd" x="#text_x_48utrd" y="200" color="#ffffff" size="30" text="foo"/>
```

**不重命名的特殊元素：**

```xml
<Image name="music_album_cover"/>    <!-- 音乐封面 -->
<Button name="music_next"/>          <!-- 下一首 -->
<Button name="music_pause"/>         <!-- 暂停 -->
<Button name="music_play"/>          <!-- 播放 -->
<Button name="music_prev"/>          <!-- 上一首 -->
<Button name="clock_button"/>        <!-- 打开时钟 -->
<Extra name="" type="" expression=""/>  <!-- Extra 标签 -->
```

## 四、插槽

### 标准插槽

通过 `<Slots/>` 标签设置插槽，外部可向插件内部添加自定义代码：

```xml
<!-- 插件定义 -->
<Template>
    <Props>
        <item name="x" default="0" type="number"/>
        <item name="y" default="0" type="number"/>
    </Props>
    <Group x="$x-1080" y="$y">
        <Slots slotName="负一屏"/>
    </Group>
    <Group x="$x" y="$y">
        <Slots slotName="正一屏"/>
    </Group>
</Template>

<!-- 使用 -->
<Plugin src="modules/mgroup" name="group1" x="300" y="100">
    <Slot>
        <Text color="#ffffff" size="50" textExp="'我是负一屏'"/>
    </Slot>
    <Slot>
        <Text color="#ffffff" size="50" textExp="'我是正一屏'"/>
    </Slot>
</Plugin>
```

### 动画插槽

通过 `<Animations/>` 标签为插件添加动画：

```xml
<!-- 插件定义 -->
<Template>
    <Animations />
    <Rectangle x="$x" y="$y" w="$w" h="$h" fillColor="#ffffff"/>
</Template>

<!-- 使用 -->
<Plugin src="modules/plugin1" name="foo">
    <Animation>
        <ScaleAnimation initPause="true" loop="false" tag="show1">
            <Item value="0" time="0" />
            <Item value="1" time="1000" />
        </ScaleAnimation>
    </Animation>
</Plugin>
```

### 事件插槽

通过 `<Emits/>` 标签为插件添加事件：

```xml
<!-- 插件定义 -->
<Template>
    <Emits x="$x" y="$y" w="$w" h="$h"/>
    <Rectangle x="$x" y="$y" w="$w" h="$h" fillColor="#ffffff"/>
</Template>

<!-- 使用 -->
<Plugin src="modules/plugin1" name="foo">
    <Emit>
        <Trigger action="down">
            <AnimationCommand target="foo" command="play" tags="show1"/>
        </Trigger>
        <Trigger action="up">
            <AnimationCommand target="foo" command="play" tags="show2"/>
        </Trigger>
    </Emit>
</Plugin>
```

## 五、全局状态管理

### 状态管理

```xml
<!-- 定义 -->
<Maml>
    <Var name="rot" expression="10" type="number" const="true"/>
    <Var name="text" expression="'hello world'" type="string" const="true"/>
</Maml>

<!-- 引入 -->
<Store src="modules/store" />

<!-- 修改 -->
<StoreCommit name="rot" expression="1000" />
```

编译后变量名为 `state.rot`、`state.text`，通过 `#state.rot` 和 `@state.text` 调用。

### 全局变量

使用 `$name$` 双 $ 符包裹避免私有化重命名：

```xml
<Var name="$move_x$" expression="300"/>
<Text text="$#move_x$"/>
```

## 六、插件间的数据通信

### 获取数据

```xml
<Plugin src="modules/plugin1" name="myPlugin"/>
<Rectangle x="get($myPlugin,#foo)" w="100" h="100" fillColor="#ffffff"/>
```

### 命令绑定

```xml
<VariableCommand name="text_value" expression="'bar'" bind="myPlugin" type="string"/>
<AnimationCommand target="init_ani" command="play(0,300)" bind="myPlugin"/>
<Command target="test.animation" value="play" bind="myPlugin"/>
<Command target="test.visibility" value="true" bind="myPlugin"/>
```

## 七、公共方法

```xml
<!-- 定义 -->
<PluginCommands>
    <Trigger action="init">
        <AnimationCommand target="ani" command="play(0,300)"/>
    </Trigger>
    <Trigger action="exit">
        <AnimationCommand target="ani" command="play(300,0)"/>
    </Trigger>
</PluginCommands>

<!-- 调用 -->
<PluginCommand target="pluginName" command="init" />
<PluginCommand target="pluginName" command="exit" />
```

## 八、功能个性化定制

### 选择器（Select）

通过 `<Select>` 根据参数选择性地编译不同代码：

```xml
<Template>
    <Props>
        <item name="type" default="0" type="select" description="解锁方式,0上划,1下划,2左划,3右划"/>
    </Props>
    <Select index="$type">
        <Item><!-- 上划解锁代码 --></Item>
        <Item><!-- 下划解锁代码 --></Item>
        <Item><!-- 左划解锁代码 --></Item>
        <Item><!-- 右划解锁代码 --></Item>
    </Select>
</Template>
```

### 关闭功能

```xml
<Plugin src="modules/plugin1" name="aaa" circle="false"/>
```

## 九、小技巧

### 传入参数自动加引号

```xml
<Template>
    <Props>
        <item name="text" default="foo" type="string"/>
    </Props>
    <Text x="$x" y="$y" color="$color" size="$size" textExp="`$text`"/>
</Template>
```

使用时 `text="hello"` 编译为 `textExp="'hello'"`，`text="hello+world+@aaa"` 编译为 `textExp="'hello'+'world'+@aaa"`。

### 引入编辑器内置插件

```xml
<Plugin src="defaultScreen" name="defaultScreen" left_icon_src="left_icon.png" right_icon_src="right_icon.png"/>
```

---

_最近更新时间：2022/1/13_
