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

---

## 四、背屏 rearscreen 包实测形态（2026-09-11 补充 ★）

上方 `<MIUI-Theme>` 是 MTZ 主题官方标准形态；**AI 壁纸 rearscreen 驱动（.ai_wallpaper/maml/<id>/rearscreen.zip）实测用 `<theme>` 根标签**（漫游宇宙、星舰矩阵时钟均验证可用）：

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<theme>
  <version><![CDATA[1.1]]></version>
  <uiVersion>12</uiVersion>
  <author><![CDATA[作者]]></author>
  <designer><![CDATA[设计者]]></designer>
  <title><![CDATA[主题名]]></title>
  <description><![CDATA[主题描述]]></description>
  <appName/>
  <typeTag></typeTag>
  <frame>0</frame>
  <editable>true</editable>
  <customEditLink>true</customEditLink>
  <resourceType>wallpaper</resourceType>
  <authors><author locale="zh_CN"><![CDATA[作者]]></author></authors>
  <designers><designer locale="zh_CN"><![CDATA[设计者]]></designer></designers>
  <titles><title locale="zh_CN"><![CDATA[主题名]]></title></titles>
  <descriptions><description locale="zh_CN"><![CDATA[主题描述]]></description></descriptions>
  <appNames/>
</theme>
```

**规则（2026-09-11 起强制）**：
1. 主题名称/作者/设计者/描述 → 只写 description.xml（上述 `<theme>` 或 `<MIUI-Theme>` 形态视目标体系）
2. var_config.xml 根标签只保留 `<WidgetConfig version="1">` + 控制项，**不写 name/author/des/description 属性**
3. 打包后检查 var_config：若打包工具自动注入了元数据（如 miroot_theme_pack）→ 改用纯 zip 打包（`cd 主题目录 && zip -r out.zip . -x '*.bak'`）或手动移除注入的属性
4. description.xml 缺失时系统读不到主题名/作者 → 可能显示为空（rearscreen 包 4 文件齐全）

---

## 五、作者信息展示（2026-09-11 更新 ★ Text 只读为主 v1.8 跑通）

**方案 A（推荐）：Text 只读** —— 无开关、纯展示；displayTitle=作者名（标签）、item=Q群（只读值），双保险：

```xml
<Text name="author_info" displayTitle="✦ 唯梦倾城 ✦" editable="false" maxLength="30" minLength="0">
  <Language displayTitle="✦ 唯夢傾城 ✦" locale="zh_TW"/>
  <Language displayTitle="✦ 唯夢傾城 ✦" locale="zh_HK"/>
  <Language displayTitle="✦ Mengqingcheng ✦" locale="en_US"/>
  <item>Q群 2159063054</item>
</Text>
```

**方案 B（备用）：OnOff 信息行** —— 系统若对 Text 展示异常时回退：

```xml
<OnOff name="author_info" displayTitle="✦ 唯梦倾城 · Q群 2159063054 ✦" default="1">
  <Language displayTitle="✦ 唯夢傾城 · Q群 2159063054 ✦" locale="zh_TW"/>
  <Language displayTitle="✦ Mengqingcheng · QQ Group 2159063054 ✦" locale="en_US"/>
</OnOff>
```

作者/群号常量：`唯梦倾城`、Q群 `2159063054`。创建任何主题自动填充（description.xml 的 author/designer 同步写唯梦倾城）。
