# 带加速度的滑动列表

> 来源：https://zhuti.designer.xiaomi.com/docs/blog/4tr4ubjzkhs.html

请自行替换 Array 的内容为自己需要放置的内容。`listHeight` 为你要放置的内容的真实高度。

## 代码示例

```xml
<?xml version="1.0" encoding="utf-8"?>
<Lockscreen version="1" frameRate="60" displayDesktop="false" screenWidth="1080">
    <Var name="listX" expression="0" const="true"/>
    <Var name="listY" expression="100" const="true"/>
    <Var name="listHeight" expression="160*100" const="true"/>
    <Var name="viewWidth" expression="#screen_width" const="true"/>
    <Var name="viewHeight" expression="1600" const="true"/>
    <Var name="listMove" expression="min(max(#touchMove + #listMoveEase/max(#touchTime,1) , -(#listHeight-#viewHeight)) , 0)" />
    <Var name="listMoveEase">
        <VariableAnimation loop="false" initPause="true">
            <AniFrame value="0" time="0" easeType="QuintEaseOut"/>
            <AniFrame value="#distance*((#timeFlag-#touch_begin_time){400)" dtime="#touchTime*10"/>
        </VariableAnimation>
    </Var>
    <Button x="#listX" y="#listY" w="#viewWidth" h="#viewHeight">
        <Triggers>
            <Trigger action="down">
                <VariableCommand name="touchMove" expression="#listMove"/>
                <VariableCommand name="touchStart" expression="#touchMove"/>
                <Command target="listMoveEase.animation" value="play(0,0)" />
                <VariableCommand name="listOutMove" expression="0"/>
            </Trigger>
            <Trigger action="move">
                <VariableCommand name="touchDistance" expression="#touch_y - #touch_begin_y"/>
                <VariableCommand name="listOutMove" expression="ifelse(#touch_y }= #touch_begin_y,max(#touchDistance-40,0),min(#touchDistance+40,0))"/>
                <VariableCommand name="touchMove" expression="#touchStart + #listOutMove"/>
            </Trigger>
            <Trigger action="up,cancel">
                <VariableCommand name="timeFlag" expression="#time_sys"/>
                <VariableCommand name="touchTime" expression="#timeFlag-#touch_begin_time"/>
                <VariableCommand name="distance" expression="(#touch_y-#touch_begin_y)*500"/>
                <Command target="listMoveEase.animation" value="play" />
                <VariableCommand name="listOutMove" expression="0"/>
            </Trigger>
        </Triggers>
    </Button>
    <Group x="#listX" y="#listY" w="#viewWidth" h="#viewHeight" clip="true">
        <Group y="#listMove">
            <Array count="100" indexName="__l">
                <Rectangle x="540" y="#__l*160" align="center" w="1000" h="150" fillColor="#ffffff" cornerRadius="30,30"/>
                <Text x="100" y="#__l*160+75" alignV="center" color="#000000" size="50" textExp="'这是一条测试文字'+' '+#__l"/>
            </Array>
        </Group>
    </Group>
    <Text x="100" y="1800" color="#ffffff" size="50" textExp="#listOutMove"/>
</Lockscreen>
```

## 说明

结合默认锁屏框架使用时，可在默认锁屏框架的横向滑动按钮是否可见处添加 `#listOutMove==0`，这样可以跟默认锁屏框架互不冲突。

---

_最近更新时间：2020/12/27_
