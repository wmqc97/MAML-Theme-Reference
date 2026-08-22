# 21 - 性能与附录
[返回目录](00-index.md)

## 性能优化原则

| 策略 | 说明 |
|------|------|
| `const="true"` | 静态元素标记，避免重复渲染 |
| 合理 `frameRate` | 非动画场景使用较低帧率或 `frameRate="0"` |
| `layerType` | 离屏渲染层，减少重绘 |
| `useHardwareCanvas="true"` | 启用硬件加速 |
| 减少元素数量 | 合并静态元素为单张图片 |
| `visibility="0"` | 隐藏不需要的元素而非移除 |

## AOD 息屏编写规则

- 息屏显示仅渲染可见区域
- 使用低帧率降低功耗
- 避免大面积动画
- 变量变化时才触发刷新

## 常用包名/类名

| 应用 | 包名 | 入口类 |
|------|------|--------|
| 设置 | `com.android.settings` | `com.android.settings.Settings` |
| 相机 | `com.android.camera` | `com.android.camera.Camera` |
| 相册 | `com.miui.gallery` | `com.miui.gallery.activity.HomePageActivity` |
| 微信 | `com.tencent.mm` | `com.tencent.mm.ui.LauncherUI` |
| QQ | `com.tencent.mobileqq` | `com.tencent.mobileqq.activity.SplashActivity` |
| 电话 | `com.android.dialer` | `com.android.dialer.DialtactsActivity` |
| 短信 | `com.android.mms` | `com.android.mms.ui.ConversationList` |
| 浏览器 | `com.android.browser` | `com.android.browser.BrowserActivity` |
| 音乐 | `com.miui.player` | `com.miui.player.ui.MusicBrowserActivity` |
| 天气 | `com.miui.weather2` | `com.miui.weather2.ActivityWeatherMain` |
| 时钟 | `com.android.deskclock` | `com.android.deskclock.DeskClock` |
| 日历 | `com.android.calendar` | `com.android.calendar.AllInOneActivity` |
| 计算器 | `com.miui.calculator` | `com.miui.calculator.cal.CalculatorActivity` |
| 文件管理 | `com.android.fileexplorer` | `com.android.fileexplorer.FileExplorerTabActivity` |
| 便签 | `com.miui.notes` | `com.miui.notes.ui.NotesListActivity` |
| 系统更新 | `com.android.updater` | `com.android.updater.MainActivity` |
| 应用商店 | `com.xiaomi.market` | `com.xiaomi.market.ui.MainActivity` |
| 安全中心 | `com.miui.securitycenter` | `com.miui.securitycenter.MainActivity` |

## Trigger action 完整列表

| action | 说明 |
|--------|------|
| `down` | 按下 |
| `up` | 抬起 |
| `double` | 双击 |
| `init` | 初始化 |
| `end` | 结束 |
| `resume` | 恢复 |
| `pause` | 暂停 |
| `broadcast` | 广播触发 |

## Layer 元素

`<Layer>` 可优化渲染性能，但会自动置顶（z-order 最高），需注意层级搭配。
