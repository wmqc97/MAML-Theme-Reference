# 新版桌面搜索框适配

> 来源：https://zhuti.designer.xiaomi.com/docs/blog/seachbar.html

## 概述

MIUI 11 新版桌面在底部添加了系统级搜索栏。由于原有时钟插件的搜索栏会造成重复，建议在主题中移除。

## 移除旧插件方法

**插件生成的搜索栏：**

- 在主题根目录的 plugin_config.xml 文件中删除 `<clock_2x4_SearchBar/>` 标签
- 旧版插件需从 clock2x4 模块的 manifest.xml 中删除 `<SearchBar/>` 标签
- 删除多余资源并使用编辑器重新打包

**代码生成的搜索栏：**

- 删除相关代码段

## 新搜索框适配

**桌面资源路径：** `com.miui.home\res\drawable-xxhdpi\`

所需图片文件：

- `bg_search_bar_dark.png` 和 `bg_search_bar_light.png`（背景）
- `icon_search_dark.png` 和 `icon_search_light.png`（搜索图标）
- `icon_xiaoai_dark.png` 和 `icon_xiaoai_light.png`（小爱图标）

**百度搜索引擎路径：** `com.android.quicksearchbox\res\drawable-xxhdpi\`

- 包含：`ic_desktop_baidu_search_engine.png`

为在壁纸场景中获得最佳显示效果，请同时创建深色和浅色版本。可将资源拷贝到 `drawable-nxhdpi\` 目录以防止高分辨率屏幕模糊。

## 颜色自定义

| 元素     | 深色主题    | 浅色主题    | 默认        |
| -------- | ----------- | ----------- | ----------- |
| 背景     | `#D9FFFFFF` | `#D9000000` | `#D9FFFFFF` |
| 点击波纹 | `#11000000` | `#11ffffff` | `#11000000` |
| 边框宽度 | 1dp         | 1dp         | 1dp         |
| 边框颜色 | `#14000000` | `#14ffffff` | `#14000000` |

---

_最近更新时间：2020/12/25_
