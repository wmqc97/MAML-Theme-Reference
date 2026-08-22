# 07 - 锁屏元素

[返回目录](00-index.md)

## 锁屏添加壁纸

```xml
<Wallpaper/>
<Wallpaper x="#screen_width/2" y="#screen_height/2" align="center" alignV="center" blur="100" alpha="255*#defaultScreen_x/2"/>
```

## 锁屏添加文字

```xml
<Text x="50" y="500" color="#ffffff" size="48" text="hello,world!" />
```

## 锁屏插入图片

```xml
<Image x="0" y="0" src="lock_bg.jpg" />
```

## 通用元素属性

| 属性       | 说明                          |
| ---------- | ----------------------------- |
| x, y       | 相对于屏幕左上角的位置        |
| w, h       | 宽度和高度                    |
| align      | 水平对齐：left、center、right |
| alignV     | 垂直对齐：top、center、bottom |
| alpha      | 透明度 0-255（≤0 表示不可见） |
| visibility | 基于表达式，>0 表示可见       |

## 锁屏添加解锁

**使用 Button 实现滑动解锁：**

```xml
<Text x="#screen_width/2" y="#screen_height-100-#unlockMove" align="center" alignV="center" color="#ffffff" size="42" text="向上滑动解锁"/>
<Group name="Unlock" >
    <Var name="unlockMove" expression="ifelse(#unlockDown==1,max(#touch_begin_y-#touch_y,0),max(#touch_begin_y-#touch_y,0) < 300,max(#touch_begin_y-#touch_y,0)*(1-#unlockBack),0)" />
    <Var name="unlockBack">
        <VariableAnimation initPause="true" loop="false">
            <Item value="0" time="0" easeType="BounceEaseOut" />
            <Item value="1" time="300" />
        </VariableAnimation>
    </Var>
    <Button w="#screen_width" h="#screen_height" >
        <Triggers>
            <Trigger action="down">
                <VariableCommand name="unlockDown" expression="1"/>
            </Trigger>
            <Trigger action="up,cancel">
                <VariableCommand name="unlockDown" expression="0" />
                <Command target="unlockBack.animation" value="play" />
                <ExternCommand command="unlock" condition="max(#touch_begin_y-#touch_y,0) >= 300" />
            </Trigger>
        </Triggers>
    </Button>
</Group>
```

**使用 Unlocker：**

```xml
<Text x="#screen_width/2" y="#screen_height-100-#Unlocker.move_dist" align="center" alignV="center" color="#ffffff" size="42" text="向上滑动解锁"/>
<Unlocker name="Unlocker">
    <StartPoint x="0" y="0" w="1080" h="#screen_height" />
    <EndPoint x="0" y="-#screen_height" w="1080" h="#screen_height-200">
        <Path tolerance="800">
            <Position x="0" y="0" />
            <Position x="0" y="-#screen_height" />
        </Path>
    </EndPoint>
</Unlocker>
```
