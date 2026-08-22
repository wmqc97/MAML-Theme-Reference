# 15 - 命令汇总
[返回目录](00-index.md)

## 命令类型

| 命令 | 功能 |
|------|------|
| `Command` | 可见性控制 |
| `AnimationCommand` | 动画控制 |
| `SoundCommand` | 声音播放（≤500K，≤10秒） |
| `VariableCommand` | 变量运算与赋值 |
| `ExternCommand` | 系统功能调用 |
| `ExternalCommands` | 外部命令集 |
| `IntentCommand` | 打开 APP 或发送广播 |
| `FunctionCommand` | 调用自定义函数 |
| `LoopCommand` | 循环执行 |
| `IfCommand` | 条件判断 |
| `BroadcastCommand` | 发送/接收广播 |
| `SensorCommand` | 传感器开关 |
| `VideoCommand` | 视频播放控制（MIUI14） |
| `FolmeCommand` | Folme 动画状态切换 |

## ExternCommand 系统功能

| 指令 | 功能 |
|------|------|
| `unlock` | 解锁屏幕 |
| `disableChargeAnim` | 禁用充电动画 |
| `disableFod` | 禁用屏下指纹 |
| `disableFodAnim` | 禁用指纹动画 |
| `setAodMode` | 设置息屏显示模式 |
| `setScreenOffTime` | 设置熄屏时间 |
| `requestSportStep` | 请求运动步数 |

## ExternalCommands

```xml
<ExternalCommands command="resume" />
<ExternalCommands command="pause" />
<ExternalCommands command="external" />
```

## IntentCommand

打开 APP 或发送系统广播。

```xml
<IntentCommand action="android.intent.action.VIEW" 
               package="com.android.settings" 
               class="com.android.settings.Settings" />
```

可携带 Extra 参数。

## 系统开关

| 功能 | Intent |
|------|--------|
| 蓝牙 | `android.settings.BLUETOOTH_SETTINGS` |
| 数据 | `android.settings.DATA_ROAMING_SETTINGS` |
| 铃声 | `android.settings.SOUND_SETTINGS` |
| WiFi | `android.settings.WIFI_SETTINGS` |

## 充电动画与屏下指纹

```xml
<ExternCommand command="disableChargeAnim" />
<ExternCommand command="disableFod" />
<ExternCommand command="disableFodAnim" />
```
