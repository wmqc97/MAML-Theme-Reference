# 19 - 系统功能与广播
[返回目录](00-index.md)

## BroadcastCommand 广播

### 发送广播

```xml
<BroadcastCommand action="com.example.ACTION" />
<BroadcastCommand action="com.example.ACTION" 
                  extra="key1:value1,key2:value2" />
```

### 接收广播

```xml
<BroadcastCommand action="com.example.ACTION" command="receive" />
```

接收后通过 `broadcastAction` 变量获取 Action 值。

## 深色模式

| 变量 | 说明 |
|------|------|
| `#__darkmode` | 深色模式状态（0/1） |
| `#__darkmode_wallpaper` | 深色模式壁纸状态 |

壁纸主色变量：`#__wallpaper_primary_color`。

## 锁屏设置

```xml
<ExternCommand command="setAodMode" value="1" />
<ExternCommand command="setScreenOffTime" value="30000" />
```

## 多语言

变量 `#lang`：`0`=中文、`1`=英文、`2`=繁体中文。

```xml
<IfCommand expression="#lang == 0">
    <Text x="0" y="0" text="你好" />
</IfCommand>
<IfCommand expression="#lang == 1">
    <Text x="0" y="0" text="Hello" />
</IfCommand>
```
