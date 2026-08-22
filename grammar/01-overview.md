# 概述与应用

## MAML 根标签
```xml
<WidgetConfig xmlns="http://schemas.android.com/apk/res/com.miui.widget"
    description="主题描述"
    name="主题名称"
    author="作者"
    frameRate="60"
    screenWidth="1080"
    useVariableUpdater="true">
```

### 属性说明
- `frameRate`：帧率（0 为按需刷新）
- `screenWidth`：设计宽（用于坐标换算）
- `useVariableUpdater`：开启变量更新
- `extraResources`：资源适配，如 `extraResources="1080,1440"` 对应 `res/` 下 `1080/`、`1440/` 目录
- `extraScales`：布局适配，如 `extraScales="1080,2.0"` 表示宽度 1080 时缩放 2

### 动态图标 / 百变壁纸 / 百变锁屏
- 动态图标：`icons/` 目录，`manifest.xml` 中声明 `<IconConfig>`
- 百变壁纸：`wallpaper/` 目录，`manifest.xml` 中声明 `<WallpaperConfig>`
- 百变锁屏：`lockscreen/` 目录，`manifest.xml` 中声明 `<LockscreenConfig>`

### manifest.xml 形态
主题包根目录必须有 `manifest.xml`，声明模块类型、版本、入口等。

---
*最近更新时间：2020/12/30*
