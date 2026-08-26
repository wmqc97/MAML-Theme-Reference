# MAML 背屏主题 · var_config.xml 配置项完整示例

> 作者：唯梦倾城 | 涵盖所有 var_config 可配置控件类型
> 注意：var_config 仅承载可配置变量，主题元数据（name/author/version）已迁入 description.xml

---

## 一、完整模板

```xml
<?xml version="1.0" encoding="utf-8"?>
<WidgetConfig version="1" description="可调配置变量">
    <OnOff name="aodPlay" displayTitle="AOD息屏播放" default="0">
        <Language displayTitle="AOD Play" locale="en_US"/>
        <Language displayTitle="AOD息屏播放" locale="zh_CN"/>
    </OnOff>
    <Text name="customTitle" displayTitle="标题文字" editable="true" maxLength="20" minLength="0">
        <Language displayTitle="Title" locale="en_US"/>
        <Language displayTitle="标题文字" locale="zh_CN"/>
        <item>默认文字</item>
    </Text>
    <Color name="textColor" displayTitle="字体颜色">
        <Language displayTitle="Text Color" locale="en_US"/>
        <Language displayTitle="字体颜色" locale="zh_CN"/>
        <item>#FFFFFF</item>
        <item>#FF0000</item>
        <item>#00FF00</item>
        <item>#0000FF</item>
    </Color>
    <FontSize name="textSize" default="120" from="80" to="160" displayTitle="字体大小">
        <Language displayTitle="Font Size" locale="en_US"/>
        <Language displayTitle="字体大小" locale="zh_CN"/>
    </FontSize>
    <ImageSelect name="image1" displayTitle="选择图片" height="152" width="286" uiType="0">
        <Language displayTitle="Select Image" locale="en_US"/>
        <Language displayTitle="选择图片" locale="zh_CN"/>
        <item displayTitle="图片A">image/a1.png</item>
        <item displayTitle="图片B">image/a2.png</item>
        <item displayTitle="图片C">image/a3.png</item>
    </ImageSelect>
    <Spinner name="animationStyle" displayTitle="动画风格" default="0">
        <Language displayTitle="Animation Style" locale="en_US"/>
        <Language displayTitle="动画风格" locale="zh_CN"/>
        <item displayTitle="无动画" value="0"/>
        <item displayTitle="淡入淡出" value="1"/>
        <item displayTitle="滑动" value="2"/>
        <item displayTitle="弹性" value="3"/>
    </Spinner>
    <Slider name="opacity" displayTitle="透明度" default="255" from="0" to="255" step="1">
        <Language displayTitle="Opacity" locale="en_US"/>
        <Language displayTitle="透明度" locale="zh_CN"/>
    </Slider>
</WidgetConfig>
```

---

## 二、控件类型详解

### 2.1 OnOff（开关）★ 最常用

```xml
<OnOff name="开关名" displayTitle="显示标题" default="默认值">
    <Language displayTitle="多语言标题" locale="区域"/>
</OnOff>
```

| 属性 | 类型 | 必填 | 说明 |
|------|------|:--:|------|
| `name` | string | ✅ | 变量名，manifest 中用 `#name` 引用 |
| `displayTitle` | string | ✅ | 默认显示标题 |
| `default` | 0/1 | ✅ | 默认值：`0`=关，`1`=开 |

**manifest 引用方式**：
```xml
<!-- 判断是否开启 -->
<Var name="isOn" expression="#aodPlay"/>
<Group visibility="ifelse(#aodPlay==1,1,0)">
```

---

### 2.2 Text（可编辑文字）

```xml
<Text name="变量名" displayTitle="显示标题" editable="true" maxLength="最大长度" minLength="最小长度">
    <Language displayTitle="多语言标题" locale="区域"/>
    <item>默认文字</item>
</Text>
```

| 属性 | 类型 | 必填 | 说明 |
|------|------|:--:|------|
| `name` | string | ✅ | 变量名，manifest 中用 `@name` 引用 |
| `displayTitle` | string | ✅ | 默认显示标题 |
| `editable` | true/false | ❌ | 是否可编辑，默认 false |
| `maxLength` | int | ❌ | 最大字符数 |
| `minLength` | int | ❌ | 最小字符数 |
| `<item>` | string | ✅ | 默认值 |

**manifest 引用方式**：
```xml
<Text textExp="@customTitle" .../>
<Var name="titleLen" expression="len(@customTitle)"/>
```

---

### 2.3 Color（颜色选择器）

```xml
<Color name="变量名" displayTitle="显示标题">
    <Language displayTitle="多语言标题" locale="区域"/>
    <item>#FFFFFF</item>  <!-- 默认值（第一个） -->
    <item>#FF0000</item>
    <item>#00FF00</item>
</Color>
```

| 属性 | 类型 | 必填 | 说明 |
|------|------|:--:|------|
| `name` | string | ✅ | 变量名，manifest 中用 `@name` 引用 |
| `displayTitle` | string | ✅ | 默认显示标题 |
| `<item>` | #RRGGBB | ✅ | 至少一个，第一个为默认值 |

**manifest 引用方式**：
```xml
<Text color="@textColor" .../>
<Rectangle fillColor="@textColor" .../>
```

---

### 2.4 FontSize（字体大小滑块）

```xml
<FontSize name="变量名" default="默认值" from="最小值" to="最大值" displayTitle="显示标题">
    <Language displayTitle="多语言标题" locale="区域"/>
</FontSize>
```

| 属性 | 类型 | 必填 | 说明 |
|------|------|:--:|------|
| `name` | string | ✅ | 变量名，manifest 中用 `#name` 引用 |
| `default` | int | ✅ | 默认值 |
| `from` | int | ✅ | 最小值 |
| `to` | int | ✅ | 最大值 |
| `displayTitle` | string | ✅ | 默认显示标题 |

**manifest 引用方式**：
```xml
<Text size="#textSize" .../>
```

---

### 2.5 ImageSelect（图片选择器）

```xml
<ImageSelect name="变量名" displayTitle="显示标题" height="预览高" width="预览宽" uiType="0">
    <Language displayTitle="多语言标题" locale="区域"/>
    <item displayTitle="选项名">图片路径</item>
</ImageSelect>
```

| 属性 | 类型 | 必填 | 说明 |
|------|------|:--:|------|
| `name` | string | ✅ | 变量名，manifest 中用 `@name` 引用 |
| `displayTitle` | string | ✅ | 默认显示标题 |
| `height` | int | ❌ | 预览图高度 |
| `width` | int | ❌ | 预览图宽度 |
| `uiType` | 0/1 | ❌ | UI 类型 |
| `<item>` | 路径 | ✅ | 至少一个，第一个为默认值 |

**manifest 引用方式**：
```xml
<Image srcExp="@image1" .../>
```

---

### 2.6 Spinner（下拉选择器）

```xml
<Spinner name="变量名" displayTitle="显示标题" default="默认索引">
    <Language displayTitle="多语言标题" locale="区域"/>
    <item displayTitle="选项名" value="值"/>
</Spinner>
```

| 属性 | 类型 | 必填 | 说明 |
|------|------|:--:|------|
| `name` | string | ✅ | 变量名，manifest 中用 `@name` 或 `#name` 引用 |
| `displayTitle` | string | ✅ | 默认显示标题 |
| `default` | int | ✅ | 默认选项索引（从0开始） |
| `<item displayTitle>` | string | ✅ | 显示名称 |
| `<item value>` | string | ✅ | 选项值 |

**manifest 引用方式**：
```xml
<!-- 数字值 -->
<Var name="animStyle" expression="num(@animationStyle)" type="number"/>
<!-- 字符串值 -->
<Var name="animStyleStr" expression="@animationStyle" type="string"/>
```

---

### 2.7 Slider（滑动条）

```xml
<Slider name="变量名" displayTitle="显示标题" default="默认值" from="最小值" to="最大值" step="步长">
    <Language displayTitle="多语言标题" locale="区域"/>
</Slider>
```

| 属性 | 类型 | 必填 | 说明 |
|------|------|:--:|------|
| `name` | string | ✅ | 变量名，manifest 中用 `#name` 引用 |
| `default` | int | ✅ | 默认值 |
| `from` | int | ✅ | 最小值 |
| `to` | int | ✅ | 最大值 |
| `step` | int | ❌ | 步长，默认 1 |

**manifest 引用方式**：
```xml
<Rectangle alpha="#opacity" .../>
```

---

## 三、Language 多语言

所有控件都支持 `<Language>` 子节点：

```xml
<Language displayTitle="多语言标题" locale="区域"/>
```

| locale | 区域 |
|--------|------|
| `zh_CN` | 简体中文 |
| `zh_TW` | 繁体中文 |
| `en_US` | 英文 |
| `ja_JP` | 日文 |

---

## 四、manifest 引用速查

| 控件类型 | 引用前缀 | 返回类型 | 示例 |
|----------|:--:|------|------|
| `OnOff` | `#name` | number (0/1) | `#aodPlay` |
| `Text` | `@name` | string | `@customTitle` |
| `Color` | `@name` | string (#RRGGBB) | `@textColor` |
| `FontSize` | `#name` | number | `#textSize` |
| `ImageSelect` | `@name` | string (路径) | `@image1` |
| `Spinner` | `@name` | string (value) | `@animationStyle` |
| `Slider` | `#name` | number | `#opacity` |

---

## 五、最佳实践

1. **所有控件只写 `zh_CN` 的 Language**，不写多语言（除非要国际化）
2. **OnOff 是最常用的**，适合做功能开关
3. **Text 的 `editable`** 默认 false，需要用户输入时才设为 true
4. **Color 的 `<item>`** 第一个为默认值
5. **WidgetConfig 不再写 `author`/`name`**，只保留 `description="可调配置变量"`
6. **配置项命名**用驼峰或下划线，避免中文
