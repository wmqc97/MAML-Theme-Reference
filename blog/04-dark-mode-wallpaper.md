# 深色模式壁纸

> 来源：https://zhuti.designer.xiaomi.com/docs/blog/mamlDrakMode.html

## 功能介绍

MAML 能力更新，支持深色模式下调暗壁纸功能。

**新功能：**

- 百变壁纸和百变锁屏默认支持深色模式下调暗
- 新增 MAML 全局变量

**全局变量：**

| 变量                    | 说明                           | 值             |
| ----------------------- | ------------------------------ | -------------- |
| #\_\_darkmode_wallpaper | 深色模式是否开启且支持壁纸调暗 | 0=禁用，1=启用 |
| #\_\_darkmode           | 深色模式是否开启               | 0=禁用，1=启用 |

## 使用说明

设计师可使用全局变量 `__darkmode_wallpaper` 自定义"深色模式且壁纸调暗"时的显示效果。

首先在 XML 根节点添加 `customizedDarkModeWallpaper` 属性：

```xml
<?xml version="1.0" encoding="utf-8"?>
<!-- customizedDarkModeWallpaper="true" 自定义深色模式 开启 -->
<Lockscreen version="2" frameRate="60" screenWidth="1080" customizedDarkModeWallpaper="true">
    ...
</Lockscreen>
```

`customizedDarkModeWallpaper` 默认为 false。当"深色模式且壁纸调暗"开启时，默认使用统一调暗效果。设为 true 后支持自定义调暗效果。

## 百变壁纸示例

```xml
<?xml version="1.0" encoding="utf-8"?>
<MiWallpaper version="2" useVariableUpdater="DateTime.Second" screenWidth="1080" customizedDarkModeWallpaper="true">
    <Var name="bgScale" expression="ifelse(#screen_height}2160,#screen_height/2160,1)" const="true" />
    <!-- #__darkmode_wallpaper 打开深色模式并启用调暗效果时值为1；srcid="1"则显示图片"bg_1.jpg" -->
    <Image pivotX="540" pivotY="0" scale="#bgScale" src="bg.jpg" srcid="#__darkmode_wallpaper" />
</MiWallpaper>
```

## 百变锁屏示例

```xml
<?xml version="1.0" encoding="utf-8"?>
<Lockscreen version="2" frameRate="60" displayDesktop="true" screenWidth="1080" customizedDarkModeWallpaper="true">
    <Var name="bg_scale" expression="ifelse(#screen_height}2160,#screen_height/2160,1)" const="true"/>
    <Var name="bgani">
        <VariableAnimation>
            <AniFrame value="0" time="0" />
            <AniFrame value="300" time="10000"/>
        </VariableAnimation>
    </Var>
    <Var expression="#defaultScreen_x!=0" threshold="1">
        <Trigger>
            <AnimationCommand target="bgani" command="pause" condition="#defaultScreen_x!=0" />
            <AnimationCommand target="bgani" command="resume" condition="#defaultScreen_x==0" />
        </Trigger>
    </Var>
    <Var expression="#defaultScreen_y!=0" threshold="1">
        <Trigger>
            <AnimationCommand target="bgani" command="pause" condition="#defaultScreen_y!=0" />
            <AnimationCommand target="bgani" command="resume" condition="#defaultScreen_y==0" />
        </Trigger>
    </Var>
    <!-- #__darkmode_wallpaper 打开深色模式并启用调暗效果时值为1 -->
    <Image x="540" y="0" align="center" pivotX="540" pivotY="0" scale="#bg_scale" srcExp="ifelse(#__darkmode_wallpaper,'darkBg','lightBg')+'/bg1.jpg'" />
    <Image y="600" srcExp="ifelse(#__darkmode_wallpaper,'darkBg/bg.webp','lightBg/bg.webp')" srcid="int(#bgani)" w="1080" h="958" />
    <Image w="1080" h="#screen_height" srcExp="ifelse(#__darkmode_wallpaper,'darkBg','lightBg') + '/brurBg.jpg'" alpha="(#defaultScreen_x/1080)*255" visibility="#defaultScreen_x}0" />
</Lockscreen>
```

---

_最近更新时间：2020/12/30_
