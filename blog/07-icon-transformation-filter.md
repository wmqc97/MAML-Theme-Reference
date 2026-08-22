# 图标变换与滤镜

> 来源：https://zhuti.designer.xiaomi.com/docs/blog/iconTransformationFilter.html

## 图标说明

主题包中的 icons 文件包含替换的图标资源。命名规则：

- **每个 APK 一个桌面图标：** 以包名命名（如 `com.android.camera.png`）
- **每个 APK 多个桌面图标：** 以 ActivityName 命名（如 `com.google.android.maps.PlacesActivity.png`）
- **不同包有相同 Activity：** 命名为 `ActivityName @PackageName`

当前小米主题图标标准尺寸：**168×168 画布**（系统默认图标画布内实际大小：156×156）

## 获取包名的方法

1. 在小米应用商店搜索（http://app.mi.com/）
2. 使用腾讯应用宝网页（https://sj.qq.com/myapp/）
3. 长按设备上的应用图标 → 应用信息 → 点击信息图标

## 功能介绍

主题编辑器支持图标变换，包含两个主要功能：

1. 图标形状和位置变换
2. 图标滤镜叠加

### 图标变换

形状和位置变化调整四个顶点位置。画布大小为 90×90，坐标可以是超出画布边界的负值。

### 图标滤镜

四种滤镜类型：

- **色阶调整**（Levels adjustment）
- **色相饱和度亮度调整**（Hue/Saturation/Brightness adjustment）
- **渐变映射**（Gradient mapping）
- **查找边缘**（Find edges）

常见滤镜组合：

- 查找边缘 + 渐变映射
- 色阶调整 + 色相饱和度亮度调整
- 渐变映射 + 色相饱和度亮度调整

---

_最近更新时间：2023/6/15_
