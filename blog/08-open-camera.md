# 锁屏进入相机方式

> 来源：https://zhuti.designer.xiaomi.com/docs/blog/openCamera.html

强大的百变锁屏可以帮助我们实现不同的视觉交互效果，同时也可以通过一些接口，打开相应的系统功能。随着小米的成长与主题使用者的增加，大家在制作各种百变锁屏的同时，也需要照顾到使用者的习惯。

系统为避免锁屏误触打开相机等情况，已将默认进入相机的方式改为了按住右下方相机小图标左滑进入。

## 一、系统样式布局

若相机小图标在右下角（与系统默认效果相似），则进入相机方式需与系统保持一致。

两种推荐方式：

1. 使用编辑器中锁屏插件：【锁屏--百变锁屏--锁屏框架--简版锁屏/上滑解锁框架/工具负一屏含框架】
2. 手动编写百变锁屏代码逻辑（含优化动画）

特别提醒：若未使用建议中的两种方式，且相机小图标在右下角，则由官方审核判断是否符合系统默认进入相机效果。

## 二、非系统样式布局

若相机小图标在其他位置（非屏幕右下角），请自行判断进入相机方式是否存在学习难度。若方式合理且不会造成困扰，可在上传审核时备注。

## 百变锁屏代码逻辑

```xml
<?xml version="1.0" encoding="utf-8"?>
<Lockscreen version="1" screenWidth="1080" frameRate="30" displayDesktop="false">
    <ExternalCommands>
        <Trigger action="init">
            <VariableCommand name="unlockButtonSwitch" expression="1" />
            <VariableCommand name="DS_cameraHint" type="string" expression="'滑动图标进相机'" />
            <VariableCommand name="DS_unlockStr" type="string" expression="'上滑解锁'" />
        </Trigger>
        <Trigger action="resume">
            <VariableCommand name="DS_moveX" expression="0" />
            <VariableCommand name="DS_moveY" expression="0" />
            <VariableCommand name="DS_moveA" expression="0" />
            <VariableCommand name="DS_moveB" expression="0" />
            <AnimationCommand target="DS_moveAn" command="play(0,0)" />
            <VariableCommand name="DS_unlockA" expression="0" />
            <AnimationCommand target="DS_unlockAn" command="play(0,0)" />
            <VariableCommand name="DS_moveX_SW" expression="0" />
            <VariableCommand name="DS_moveY_SW" expression="0" />
            <VariableCommand name="DS_unlockSW" expression="0" />
        </Trigger>
    </ExternalCommands>
    <Group visibility="#move {= 0">
        <!-- 主界面代码 -->
    </Group>
    <Group x="#move">
        <Group x="-1080" visibility="gt(#move,0)">
            <!-- 负一屏代码 -->
        </Group>
        <Group visibility="#move != 1080">
            <Group x="950-#DS_springingAn">
                <Image x="15" y="#screen_height-65" alignV="center" src="DS/camera.png" alpha="160" />
                <Text name="DS_cameraHintW" x="12" y="#screen_height-65" color="#ffffff" align="right" alignV="center" textExp="@DS_cameraHint" size="36" alpha="#DS_hintAn" />
                <Image x="0-#DS_cameraHintW.text_width" y="#screen_height-65" align="right" alignV="center" src="DS/arrow.png" alpha="#DS_hintAn" />
            </Group>
            <Image x="25" y="#screen_height-65" alignV="center" src="DS/left_icon.png" alpha="160" />
            <Text x="540" y="#DS_unlockMoveY+#screen_height-65" color="#ffffff" align="center" alignV="center" textExp="@DS_unlockStr" size="40" alpha="(160+#DS_unlockMoveY*#DS_moveY_SW/350*255)*(#DS_hintAn == 0)" />
        </Group>
    </Group>
    <Image x="1080+#move" y="0" w="1080" h="#screen_height" srcExp="'DS/right_screen/cam_bg_'+int(#screen_height == 1920)+'.9.png'" visibility="#move { 0" />
    <Var name="move" expression="max(min(#DS_moveX+int(#DS_moveAn),1080),-1080)" />
    <Var name="DS_unlockMoveY" expression="#DS_unlockAn+#DS_moveY" />
    <Var name="DS_moveAn">
        <VariableAnimation initPause="true" loop="false">
            <Item value="#DS_moveA" time="0" easeType="QuartEaseOut" />
            <Item value="#DS_moveB" time="500" />
            <Triggers>
                <Trigger action="end">
                    <VariableCommand name="DS_moveA" expression="#DS_moveB" />
                    <IntentCommand action="android.intent.action.MAIN" package="com.android.camera" class="com.android.camera.Camera" condition="#DS_moveAn == -1080">
                        <Extra name="ShowCameraWhenLocked" type="boolean" expression="1" />
                        <Extra name="StartActivityWhenLocked" type="boolean" expression="1" />
                    </IntentCommand>
                </Trigger>
            </Triggers>
        </VariableAnimation>
    </Var>
    <Var name="DS_unlockAn">
        <VariableAnimation initPause="true" loop="false">
            <Item value="#DS_unlockA" time="0" easeType="SineEaseOut" />
            <Item value="0" time="200" />
        </VariableAnimation>
    </Var>
    <Var name="DS_hintAn">
        <VariableAnimation initPause="true" loop="false">
            <Item value="0" time="0" />
            <Item value="160" time="300" />
            <Item value="160" time="1200" />
        </VariableAnimation>
    </Var>
    <Var name="DS_springingAn">
        <VariableAnimation initPause="true" loop="false">
            <Item value="0" time="0" easeType="SineEaseOut" />
            <Item value="70" time="200" easeType="BounceEaseOut" />
            <Item value="0" time="800" />
        </VariableAnimation>
    </Var>
    <FramerateController name="framerateAn" loop="false">
        <ControlPoint frameRate="30" time="0" />
        <ControlPoint frameRate="50" time="50" />
        <ControlPoint frameRate="50" time="1000" />
        <ControlPoint frameRate="30" time="1050" />
    </FramerateController>
    <Button x="0" y="0" w="1080" h="#screen_height" visibility="#unlockButtonSwitch">
        <Triggers>
            <Trigger action="down">
                <AnimationCommand target="framerateAn" command="play" />
            </Trigger>
            <Trigger action="move">
                <VariableCommand name="DS_moveY_SW" expression="1" condition="(#DS_moveX_SW == 0) ** ((#touch_y-#touch_begin_y) { -50) ** (#move == 0)" />
                <VariableCommand name="DS_moveX_SW" expression="1" condition="(#DS_moveY_SW == 0) ** (abs(#touch_begin_x-#touch_x) } 50)" />
                <VariableCommand name="DS_moveY" expression="max(-350,min(0,int(#touch_y-#touch_begin_y)))" condition="#DS_moveY_SW" />
                <MultiCommand condition="#DS_moveX_SW">
                    <VariableCommand name="DS_leftMoveSW" expression="(#touch_begin_y { (#screen_height-150)) ** (int(#DS_moveAn+#touch_x-#touch_begin_x) { 0)" />
                    <VariableCommand name="DS_moveX" expression="int(#touch_x-#touch_begin_x)" />
                    <VariableCommand name="DS_moveX" expression="max(#DS_moveX,0)" condition="#DS_leftMoveSW" />
                </MultiCommand>
            </Trigger>
            <Trigger action="up,cancel">
                <MultiCommand condition="#DS_moveY_SW">
                    <ExternCommand command="unlock" condition="#DS_moveY == -350" />
                    <VariableCommand name="DS_unlockSW" expression="#DS_moveY == -350" />
                    <MultiCommand condition="#DS_moveY } -350">
                        <VariableCommand name="DS_unlockA" expression="#DS_moveY" />
                        <VariableCommand name="DS_moveY" expression="0" />
                        <AnimationCommand target="DS_unlockAn" command="play" />
                    </MultiCommand>
                </MultiCommand>
                <MultiCommand condition="#DS_moveX_SW">
                    <VariableCommand name="DS_direction" expression="((#touch_x } #touch_begin_x)*2-1)*(abs(#DS_moveX) } 200)*(#move { 1080)*(#move } -1080)" />
                    <MultiCommand condition="#DS_moveX != 0">
                        <VariableCommand name="DS_moveA" expression="#move" />
                        <VariableCommand name="DS_moveB" expression="#DS_moveB+#DS_direction*1080" />
                        <VariableCommand name="DS_moveX" expression="0" />
                        <AnimationCommand target="DS_moveAn" command="play" />
                    </MultiCommand>
                    <MultiCommand condition="#DS_direction == 0 ** #touch_x { #touch_begin_x">
                        <AnimationCommand target="DS_hintAn" command="play(1200,0)" />
                        <AnimationCommand target="DS_springingAn" command="play" />
                    </MultiCommand>
                </MultiCommand>
                <VariableCommand name="DS_moveY_SW" expression="0" condition="!#DS_unlockSW" />
                <VariableCommand name="DS_moveX_SW" expression="0" />
            </Trigger>
        </Triggers>
    </Button>
</Lockscreen>
```

---

_最近更新时间：2020/12/25_
