# 运动计步

> 来源：https://zhuti.designer.xiaomi.com/docs/blog/MiStep.html

## 新版计步

旧版计步数据获取比较复杂，且无法获取目标步数、公里数、卡路里等，故增加通过「小米健康」获取数据的方式（仅支持 MIUI12 使用）。

```xml
<ExternalCommands>
    <Trigger action="resume">
        <!-- 开屏刷新 运动记录数据 -->
        <BinderCommand name="MiSteps" command="refresh" />
    </Trigger>
</ExternalCommands>

<VariableBinders>
    <!-- 注意：不可卸载 小米健康App -->
    <ContentProviderBinder name="MiSteps" uri="content://com.mi.health.provider.main/activity/steps/brief" column="steps,goal,distance,energy,strength_duration,summary" countName="hasSteps">
        <Variable name="MiSteps_steps" type="string" column="steps"/>
        <Variable name="MiSteps_goal" type="string" column="goal"/>
        <Variable name="MiSteps_distance" type="string" column="distance"/>
        <Variable name="MiSteps_energy" type="string" column="energy"/>
        <Variable name="MiSteps_strength_duration" type="string" column="strength_duration"/>
        <Variable name="MiSteps_summary" type="string" column="summary"/>
    </ContentProviderBinder>
</VariableBinders>

<Text x="100" y="300" alignV="center" color="#ffffffff" size="42" textExp="'今日步数：' +@MiSteps_steps+ '步'"/>
```

### 属性表

| 属性              | 释义                                                  | 单位      | 类型   |
| ----------------- | ----------------------------------------------------- | --------- | ------ |
| steps             | 步数                                                  | 步        | string |
| goal              | 目标步数                                              | 步        | string |
| distance          | 距离                                                  | 公里 km   | string |
| energy            | 消耗卡路里                                            | 千卡 kcal | string |
| strength_duration | 运动中高强度时长                                      | 分钟      | string |
| summary           | 运动是否达标；0 暂无 1 尚未达标 2 运动不足 3 运动达标 | —         | string |

### 异常处理

- 未安装「小米健康」app 时，点击跳转至应用商店下载页面
- 已安装但从未打开时提示用户获取数据，点击后跳转健康运动页面

```xml
<!-- 判断是否有小米健康应用 -->
<Image name="app_health" x="0" y="0" w="168" h="168" srcType="ApplicationIcon" srcExp="'com.mi.health,com.mi.health.home.HomeActivity'" alpha="0"/>
<Button x="540" y="1000" w="300" h="140" align="center" alignV="center" alignChildren="true">
    <Normal>
        <Rectangle w="300" h="140" fillColor="#33ffffff" cornerRadius="70"/>
    </Normal>
    <Pressed>
        <Rectangle w="300" h="140" fillColor="#66ffffff" cornerRadius="70"/>
    </Pressed>
    <Text x="150" y="70" align="center" alignV="center" color="#ffffffff" size="42" textExp="ifelse(#app_health.bmp_width,'打开','安装')"/>
    <Text x="150" y="-60" align="center" alignV="center" color="#ffffffff" size="39" textExp="ifelse(!#app_health.bmp_width,'无法获取数据，请安装小米健康',strIsEmpty(@MiSteps_goal),'点击获取数据','查看运动详情')"/>
    <Triggers>
        <Trigger action="up">
            <ExternCommand command="unlock"/>
            <!-- 未安装 跳转到应用商店 -->
            <IntentCommand action="android.intent.action.VIEW" uri="market://details?id=com.mi.health&amp;ref=mithemelocksreen" flags="268435456" condition="!#app_health.bmp_width" />
            <!-- 已安装 打开运动页面 -->
            <IntentCommand action="android.intent.action.VIEW" uri="com.mi.health://localhost/d?action=steps&amp;origin=mithemelocksreen" condition="#app_health.bmp_width"/>
        </Trigger>
    </Triggers>
</Button>
```

> 注意：上面的新版计步只有 MIUI12 支持。适配 MIUI11 时注意设计与制作兼容，在 V11 的主题版本上可使用下面的旧版代码。

---

## 旧版计步

数据来源：小米计步

```xml
<VariableBinders>
  <ContentProviderBinder name="MiStep" uri="content://com.miui.providers.steps/item" columns="_id,_begin_time,_end_time,_mode,_steps" countName="hassteps" whereFormat="_begin_time>='%d'" whereParas="int((#time_sys-#hour24*3600000-#minute*60000-#second*1000)/1000)*1000">
    <Variable name="Mi_step" type="string[]" column="_steps"/>
    <Variable name="Mi_begin_time" type="string[]" column="_begin_time"/>
    <Variable name="Mi_end_time" type="string[]" column="_end_time"/>
    <Trigger>
      <!-- 初始化今天的总步数 -->
      <VariableCommand name="step_today" expression="0" />
      <!-- 计算今天的总步数 -->
      <LoopCommand count="#hassteps" indexName="__s">
        <VariableCommand name="step_today" expression="#step_today+int(@Mi_step[#__s])" />
      </LoopCommand>
    </Trigger>
  </ContentProviderBinder>
</VariableBinders>
<Text x="100" y="100" color="#ffffff" size="40" textExp="#step_today"/>
```

### 参数表

| 参数名称     | 含义                                                             | 类型     |
| ------------ | ---------------------------------------------------------------- | -------- |
| \_id         | 记录在 sqlite 的 id，从 1 开始计                                 | string[] |
| \_begin_time | 计步打点开始时间                                                 | string[] |
| \_end_time   | 计步打点结束时间                                                 | string[] |
| \_steps      | 每次打点的步数                                                   | string[] |
| \_mode       | 计步模式：0=不支持, 1=静止, 2=走路, 3=跑步, 11=骑车, 12=交通工具 | string[] |

---

_最近更新时间：2020/12/30_
