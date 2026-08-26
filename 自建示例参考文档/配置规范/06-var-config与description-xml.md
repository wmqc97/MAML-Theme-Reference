# MAML 背屏主题 · var_config 与 description.xml 规范

> 作者：唯梦倾城 | 合并自"背屏MAML主题写法参考" + "语法整合参考" + "移植方案"

---

## 一、description.xml（MIUI 官方标准元数据）★ 新标准

**从此文件承载主题信息，不再写入 var_config。**

```xml
<?xml version="1.0" encoding="utf-8"?>
<MIUI-Theme>
    <osVersion>4</osVersion>
    <version>36</version>
    <title>小萌背屏</title>
    <titles>
        <title locale="zh_CN">小萌背屏</title>
    </titles>
    <author>唯梦倾城</author>
    <designer>唯梦倾城</designer>
    <description>罗小黑GIF动态背屏，251帧逐帧动画，支持主屏亮灭联动</description>
    <descriptions>
        <description locale="zh_CN">罗小黑GIF动态背屏，251帧逐帧动画，支持主屏亮灭联动</description>
    </descriptions>
    <uiVersion>0</uiVersion>
    <type>widgets</type>
    <preview>effect.png</preview>
    <size>7.5M</size>
    <theme_bind>com.android.thememanager</theme_bind>
    <bind>
        <pkg>com.android.thememanager</pkg>
        <actions>click,show</actions>
    </bind>
    <screen>0</screen>
    <home>true</home>
    <third>true</third>
    <widgets>widgets</widgets>
</MIUI-Theme>
```

### 字段说明

| 字段 | 类型 | 说明 |
|------|------|------|
| `osVersion` | 固定 | `4`，MIUI 主题框架版本 |
| `version` | 整数 | 主题版本号（build 号） |
| `title` + `titles` | 文本 | 主题名称（不含版本号） |
| `author` | 文本 | 作者署名 |
| `designer` | 文本 | 设计者 |
| `description` + `descriptions` | 文本 | 主题描述 |
| `type` | 固定 | `widgets`（背屏小组件） |
| `preview` | 路径 | 预览图文件名 |
| `theme_bind` / `bind` | 包名 | 绑定应用 |

---

## 二、var_config.xml（仅保留可配置变量）

**不再承载 name/author/description 等元数据。**

```xml
<?xml version="1.0" encoding="utf-8"?>
<WidgetConfig version="1" description="可调配置变量">
    <OnOff name="aodPlay" displayTitle="AOD息屏播放" default="0">
        <Language displayTitle="AOD Play" locale="en_US"/>
        <Language displayTitle="AOD息屏播放" locale="zh_CN"/>
    </OnOff>
    <OnOff name="hideCapsule" displayTitle="隐藏电量胶囊" default="0"/>
    <Text name="customTitle" displayTitle="标题文字" editable="true" maxLength="20" minLength="0">
        <item>默认文字</item>
    </Text>
    <Color name="textColor" displayTitle="字体颜色">
        <item>#FFFFFF</item>
        <item>#FF0000</item>
    </Color>
    <FontSize name="textSize" default="120" from="80" to="160" displayTitle="字体大小"/>
    <ImageSelect name="image1" displayTitle="选择图片" height="152" width="286" uiType="0">
        <item displayTitle="图1">image/a1.png</item>
        <item displayTitle="图2">image/a2.png</item>
    </ImageSelect>
</WidgetConfig>
```

### 配置项在 manifest 中的引用

- `OnOff` 开关返回 0/1 → `#hideCapsule` 引用
- `Text` 字符串 → `@customTitle` 引用
- `Color` → 颜色值字符串

### 核心原则：写入与读取分离

```
description.xml ← 元数据唯一写入目标
     │
 ┌───┼───┐
 ▼   ▼   ▼
pack scaffold editor → 只写 description.xml，不写 var_config 元数据
     │
     ▼
var_config.xml ← 仅保留 OnOff/Spinner 等变量，不写元数据
```

| 操作 | description.xml | var_config 元数据属性 |
|------|:--:|:--:|
| 新包生成（pack/scaffold/editor） | ✅ 写入 | ❌ 不写入 |
| 旧包读取（parse/read_entry） | ✅ 优先读取 | ✅ 兼容回退 |

---

## 三、manifest.xml 版本号

```xml
<Widget version="36" frameRate="0" ...>
```
- `version` 属性为整数 build 号，从 `description.xml` 的 `<version>` 同步
- var_config 不再承载版本号
