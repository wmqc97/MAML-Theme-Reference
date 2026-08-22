# 屏下指纹

> 来源：https://zhuti.designer.xiaomi.com/docs/blog/mamlFod.html

## 功能说明

目前部分小米手机支持屏下指纹功能，开启后可能会影响百变锁屏的内容显示或带来不佳的用户体验。百变锁屏支持禁用此功能。

**重要限制：** 仅在必要的交互场景中允许禁用指纹，如"从锁屏进入相机、进入负一屏、或进入锁屏游戏"等。**在默认非交互场景中禁止禁用指纹。**

## 控制命令

| 命令           | 说明         | 参数           |
| -------------- | ------------ | -------------- |
| disableFod     | 控制指纹开关 | 0=启用，1=禁用 |
| disableFodAnim | 控制识别动画 | 0=启用，1=禁用 |

## 代码示例

```xml
<!-- 禁用指纹 -->
<ExternalCommands>
    <Trigger action="init">
        <ExternCommand command="disableFod" numPara="1"/>
    </Trigger>
</ExternalCommands>

<!-- 启用指纹 -->
<ExternalCommands>
    <Trigger action="init">
        <ExternCommand command="disableFod" numPara="0"/>
    </Trigger>
</ExternalCommands>

<!-- 禁用指纹动画 -->
<ExternalCommands>
    <Trigger action="init">
        <ExternCommand command="disableFodAnim" numPara="1"/>
    </Trigger>
</ExternalCommands>

<!-- 启用指纹动画 -->
<ExternalCommands>
    <Trigger action="init">
        <ExternCommand command="disableFodAnim" numPara="0"/>
    </Trigger>
</ExternalCommands>
```

## 全局变量

| 变量                     | 说明                                               |
| ------------------------ | -------------------------------------------------- |
| #fod_enable              | 系统是否开启指纹（0=关，1=开）                     |
| #fod_x / #fod_y          | 指纹区域坐标                                       |
| #fod_width / #fod_height | 指纹区域尺寸                                       |
| #fod_state_msg           | 手指状态（1=按下，2=抬起，3=识别失败，4=识别成功） |

---

_最近更新时间：2020/12/30_
