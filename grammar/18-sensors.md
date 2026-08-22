# 18 - 传感器
[返回目录](00-index.md)

## 传感器类型

| 变量 | 说明 |
|------|------|
| `#gravity_x` / `#gravity_y` / `#gravity_z` | 重力传感器 |
| `#azimuth` | 方位角 |
| `#pitch` | 俯仰角 |
| `#roll` | 翻滚角 |
| `#acceleration_x` / `#acceleration_y` / `#acceleration_z` | 加速度计 |
| `#accelerometer_x` / `#accelerometer_y` / `#accelerometer_z` | 线性加速度 |
| `#pressure_value` | 气压值 |

## SensorCommand 启动传感器

```xml
<SensorCommand type="gravity" command="enable" interval="100" />
```

参数：
- `type`：传感器类型
- `command`：`enable` / `disable`
- `interval`：采样间隔（毫秒），默认 100ms

## 完整示例

```xml
<!-- 启动重力传感器 -->
<SensorCommand type="gravity" command="enable" interval="50" />

<!-- 使用传感器数据控制元素 -->
<Image x="0" y="0" src="ball.png">
    <VariableCommand name="x" expression="#gravity_x * 100" />
    <VariableCommand name="y" expression="#gravity_y * 100" />
</Image>
```
