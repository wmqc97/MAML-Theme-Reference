# MAML 背屏主题 · AOD 与省电实践

> 作者：唯梦倾城 | 合并自"背屏MAML主题写法参考" + "语法整合参考"

---

## 一、AOD 状态机

### 状态变量

```xml
<!-- 可变状态变量（无 expression，由事件驱动） -->
<Var name="aodState" type="number"/>
```

`aodState` 含义：
- `1`：亮屏状态
- `0`：已进入 AOD
- 0.1：正在退出 AOD（过渡）
- 0.9：正在进入 AOD（过渡）

### 系统变量兜底

```xml
<!-- 系统注入的 AOD 状态，字符串 "1"=AOD "0"=亮屏，永不被表达式覆盖 -->
@aod_desk_state
```

---

## 二、AOD 省电核心策略

### 三重保险（充电/动态动画可见性）

```xml
<Var name="chargeFlowVisible" type="number"
     expression="ifelse(eqs(@aod_desk_state,'1'), 0,     ← 系统变量：AOD 隐藏
                 ifelse(#aodState == 0, 0,               ← 事件变量：AOD 隐藏
                 ifelse(#batteryPlugType } 0, 1, 0)))"/>  ← 充电才显示
```

### 生命周期事件控制

```xml
<ExternalCommands>
    <!-- AOD 进入：停动画、降帧率、隐藏 -->
    <Trigger action="enterAod">
        <VariableCommand name="aodState" expression="0" type="number"/>
        <AnimationCommand target="chargeAnim" command="pause"/>
        <VariableCommand name="chargeAnim" expression="0" type="number"/>
        <FrameRateCommand rate="0"/>
    </Trigger>

    <!-- AOD 退出：恢复动画、升帧率、显示 -->
    <Trigger action="exitAod">
        <VariableCommand name="aodState" expression="1" type="number"/>
        <AnimationCommand target="chargeAnim" command="play"/>
        <FrameRateCommand rate="60"/>
    </Trigger>

    <!-- pause/resume 同理 -->
    <Trigger action="pause">
        <AnimationCommand target="chargeAnim" command="pause"/>
        <FrameRateCommand rate="0"/>
    </Trigger>
    <Trigger action="resume">
        <AnimationCommand target="chargeAnim" command="play"/>
        <FrameRateCommand rate="60"/>
    </Trigger>
</ExternalCommands>
```

### AOD 调暗蒙版

```xml
<Var name="__isAod" expression="#aodState==0"/>
<Rectangle x="0" y="0" w="#view_width" h="#view_height"
           fillColor="#000000" alpha="180" visibility="#__isAod"/>
```

### 刷新门控（AOD 下停止每秒刷新省电）

```xml
<Function name="checkTick">
    <IfCommand ifCondition="(#aodState == 1)">
        <Consequent>
            <BinderCommand name="getData" command="refresh"/>
        </Consequent>
    </IfCommand>
</Function>
```

---

## 三、AOD 判断准则

1. **优先用系统 `aod_desk_state`**：由背屏直接 putVariableString 写入，永不被表达式覆盖
2. **事件变量 `aodState` 为辅**：由 enterAod/exitAod 设置
3. **两者结合做三重保险**：确保 AOD 下动画绝对隐藏

---

## 四、帧率相关常量

```xml
<Var name="_maml_rate" expression="75" const="true"/>
<Var name="_gl_rate" expression="0" const="true"/>
<Var name="PHYSICS_FPS" expression="60" type="number" const="true"/>
<Var name="FIXED_DELTA" expression="1.0/#PHYSICS_FPS" type="number" const="true"/>
<Var name="MAX_PHYSICS_STEPS" expression="5" type="number" const="true"/>
```

---

## 五、AOD 状态下传感器管理

```xml
<!-- 进入 AOD 时关闭传感器 -->
<Function name="_stop_sensor">
    <SensorCommand target="sensor" command="turnOff"/>
    <VariableCommand name="sensor_enable" expression="0"/>
</Function>

<!-- 退出 AOD 时恢复传感器 -->
<Function name="_start_sensor">
    <FunctionCommand target="_clear_camera_data"/>
    <VariableCommand name="_time_last" expression="#time_sys"/>
    <SensorCommand target="sensor" command="turnOn"/>
    <VariableCommand name="sensor_enable" expression="1"/>
    <AnimationCommand target="_ticker" command="play" tags="loop" delay="20"/>
</Function>
```

---

## 六、AOD 省电最佳实践总结

```
1. 充电/动态动画可见性：三重保险
   - eqs(@aod_desk_state,'1') → 隐藏
   - #aodState == 0 → 隐藏
   - #batteryPlugType } 0 → 显示

2. enterAod/pause：AnimationCommand pause + FrameRateCommand rate="0"
3. exitAod/resume/init：AnimationCommand play + FrameRateCommand rate="60"
4. AOD 蒙版：Rectangle fillColor="#000000" alpha="180" visibility="#isAod"
5. 刷新门控：AOD 下跳过数据刷新节省 CPU
6. 传感器：AOD 下 turnOff 避免无意义计算
```
