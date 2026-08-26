# 命令汇总与控件用法

> 来源：https://zhuti.designer.xiaomi.com/docs/grammar/

所有命令必须放在 `Trigger` 标签内，否则不会生效。

---

## 可见性命令（Command）

```xml
<Command target="elementName" property="visibility" value="true"/>
<Command target="elementName" property="visibility" value="false"/>
<Command target="elementName" property="visibility" value="toggle"/>
```

| 属性 | 释义 |
|------|------|
| `target` | 控制目标名 |
| `property` | 属性名，目前支持 `visibility` |
| `value` | 属性值：`true`、`false`、`toggle` |

---

## 动画命令（AnimationCommand）

```xml
<AnimationCommand target="ani" command="play"/>
<AnimationCommand target="ani" command="play(0,500)"/>
<AnimationCommand target="ani" command="pause"/>
<AnimationCommand target="ani" command="resume"/>
```

---

## 声音命令（SoundCommand）

```xml
<SoundCommand sound="click.mp3" volume="0.8" loop="false" keepCur="false"/>
```

| 属性 | 释义 |
|------|------|
| `sound` | 声音文件路径名 |
| `volume` | 声音大小，0~1 的浮点数 |
| `loop` | 是否循环播放，true/false，默认 false |
| `keepCur` | 播放此音频时是否保持当前正在播放的声音，默认 false |

> 注意：声音文件大小不超过500kB，时长不超过10秒。

---

## 变量命令（VariableCommand）

```xml
<VariableCommand name="a" expression="#a+1"/>
<VariableCommand name="a" expression="300" condition="#a{100"/>
<VariableCommand name="a" expression="0" delay="500"/>
```

| 属性 | 释义 |
|------|------|
| `name` | 变量名 |
| `expression` | 赋值表达式 |
| `condition` | 条件判断，为真时执行 |
| `delay` | 延迟执行（毫秒） |
| `delayCondition` | 延时判断，在 delay 时间之后再进行判断 |

---

## 帧率命令（FrameRateCommand）

```xml
<FrameRateCommand rate="120"/>  <!-- 提高帧率 -->
<FrameRateCommand rate="0"/>    <!-- 停止渲染 -->
```

---

## 打开程序（IntentCommand）

```xml
<!-- 通过包名/类名打开应用 -->
<IntentCommand action="android.intent.action.MAIN"
    package="com.android.thememanager"
    class="com.android.thememanager.ThemeResourceTabActivity"/>

<!-- 打开 URL -->
<IntentCommand action="android.intent.action.VIEW"
    package="com.android.browser"
    class="com.android.browser.BrowserActivity"
    uriExp="'www.mi.com'"/>

<!-- deeplink 打开快应用 -->
<IntentCommand uri="com.miui.hybrid://hybrid.xiaomi.com/app/com.yidian.hybrid.main"/>

<!-- 发送广播 -->
<IntentCommand action="BROADCAST_ACTION_NAME" broadcast="true"/>
<IntentCommand action="BROADCAST_ACTION_NAME" broadcast="true">
    <Extra name="key" type="number" expression="1000"/>
</IntentCommand>
```

### 常用系统开关

```xml
<!-- 开关蓝牙（锁屏正常支持，MIUI14以下版本小部件支持） -->
<ExternCommand command="bluetooth" numPara="state,ifelse(#bluetooth_state==1,0,1)"/>

<!-- 切换铃声模式（锁屏正常支持） -->
<ExternCommand command="ring_mode" numPara="mode,ifelse(#ring_mode==2,1,2)"/>

<!-- 开关WiFi -->
<ExternCommand command="wifi" numPara="state,ifelse(#wifi_state==1,0,1)"/>
```

| 变量 | 说明 |
|------|------|
| `bluetooth_state` | 0=关，1=开，2=连接中 |
| `data_state` | 0=关，1=开 |
| `ring_mode` | 0=静音，1=振动，2=正常 |
| `wifi_state` | 0=禁用，1=启用，2=问题，3=连接中 |

---

## 外部命令（ExternCommand / ExternalCommand）

```xml
<!-- 向外部程序发送命令 -->
<ExternCommand command="unlock"/>
<ExternCommand command="disableFod" numPara="0"/>

<!-- 接收外部命令（一个XML文件只支持一个 ExternalCommands） -->
<ExternalCommands>
    <Trigger action="init">...</Trigger>
    <Trigger action="pause">...</Trigger>
    <Trigger action="resume">...</Trigger>
    <Trigger action="customAction">...</Trigger>
</ExternalCommands>
```

---

## 按钮（Button）

| 属性 | 释义 |
|------|------|
| `x, y, w, h` | 坐标和区域大小 |
| `haptic` | true 时振动（前提是用户没有在系统设置中关闭） |
| `alignChildren` | true=内部元素按绝对坐标排布，false=相对坐标（默认） |
| `interceptTouch` | 是否截获后续触摸事件 |
| `Normal` | 正常状态，包含的元素只在此状态下显示 |
| `Pressed` | 按下状态，包含的元素只在此状态下显示 |

Trigger action 值：`down`（按下）、`up`（抬起）、`move`（移动）、`double`（双击）

```xml
<Button x="0" y="0" w="#screen_width" h="#screen_height" interceptTouch="true">
    <Triggers>
        <Trigger action="down">
            <VariableCommand name="pressed" expression="1"/>
        </Trigger>
        <Trigger action="up">
            <VariableCommand name="pressed" expression="0"/>
            <IntentCommand action="android.intent.action.MAIN"
                package="com.miui.calculator"
                class="com.miui.calculator.cal.CalculatorActivity"/>
            <ExternCommand command="unlock"/>
        </Trigger>
    </Triggers>
    <Normal>
        <Image src="btn_normal.png" x="0" y="0" w="200" h="80"/>
    </Normal>
    <Pressed>
        <Image src="btn_pressed.png" x="0" y="0" w="200" h="80"/>
    </Pressed>
</Button>
```

### 上滑手势解锁示例

```xml
<Button x="0" y="0" w="#screen_width" h="#screen_height">
    <Triggers>
        <Trigger action="up" condition="#touch_begin_y - #touch_y } 100">
            <ExternCommand command="unlock"/>
        </Trigger>
    </Triggers>
</Button>
```

---

## 滑动控件（Unlocker / Slider）

Unlocker 能直接解锁，Slider 需要加入解锁命令，用法相同。

| 属性 | 释义 |
|------|------|
| `StartPoint` | 起始点 |
| `EndPoint` | 目标点 |
| `haptic` | true 时振动 |
| `alignChildren` | true=内部元素按绝对坐标排布 |
| `easeType` / `easeExp` | 缓动类型 |
| `easeTime` | 缓动时间 |
| `alwaysShow` | 默认 false，当一个 Slider 可见时其他 Slider 消失 |
| `NormalState` | 正常状态 |
| `PressedState` | 按下状态 |
| `ReachedState` | 激活状态 |

---

## 屏下指纹控制

```xml
<!-- 关闭屏下指纹功能（仅在必要交互时使用） -->
<ExternCommand command="disableFod" numPara="1"/>

<!-- 开启屏下指纹功能 -->
<ExternCommand command="disableFod" numPara="0"/>

<!-- 关闭指纹识别动画 -->
<ExternCommand command="disableFodAnim" numPara="1"/>
```

---

## 充电动画控制

```xml
<!-- 关闭进入充电状态时刻的默认充电动画 -->
<ExternCommand command="disableChargeAnim" numPara="1"/>

<!-- 显示默认充电动画 -->
<ExternCommand command="disableChargeAnim" numPara="0"/>
```
