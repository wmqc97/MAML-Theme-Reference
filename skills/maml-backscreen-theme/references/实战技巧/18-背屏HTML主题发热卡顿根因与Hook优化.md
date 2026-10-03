# 18-背屏HTML主题发热卡顿根因与Hook优化（2026-09-15 反编译实证）

> 问题：背屏使用 HTML 主题（WebView）导致手机发热、卡顿
> 结论：**AOD/息屏后 WebView 从不暂停，JS 定时器+CSS动画+Chromium渲染持续跑**
> 反编译：subscreen.apk v426082119（com.xiaomi.subscreencenter）

---

## 一、发热卡顿根因（反编译完整证据链）

### 1.1 背屏 AOD 状态处理流程（实证）

```
MainPanel.B(Z)  [onAodStateChanged inAod=?]
  → new Lk2/x(...) + u(Lk2/A)    // 延迟执行
  → Lk2/x.a() case 0x1 (AOD)
      → MainPanel.u = inAod
      → MainPanel.H()
      → LE2/w.y(inAod)           // widget 的 AOD 处理
          → if 首次唤醒 force_non_aod_state: 跳过
          → LE2/j.n(inAod)       // MamlWidget 的 AOD
              → LE2/i.e(inAod)   // MamlView 子类
                  → putVariableString("inAod", "1"/"0")  // ★只通知 HTML
                  → sendCommand  // 发 MAML 命令
                  → ✗✗✗ 没有 onPause / WebView 暂停 ✗✗✗
```

### 1.2 核心发现：`LE2/i.e(Z)`（AOD）只通知不暂停

```java
// LE2/i.e(Z) 反编译
void e(boolean inAod) {
    if (mRoot == null || e == inAod) return;
    e = inAod;
    putVariableString("inAod", inAod ? "1" : "0");  // HTML 侧可读 #inAod
    sendCommand(...);  // 发 MAML 命令
    // ❌ 没有调用 MamlView.onPause()
    // ❌ 没有调用 WebView.onPause()
    // ❌ 没有停止 Chromium 渲染
}
```

### 1.3 对比：真正的暂停只在不可见时

```java
// LE2/i.onPause()（会真正暂停）只在以下场景触发：
// - MamlView.onDetachedFromWindow() → onPause
// - MamlView.setVisibility(GONE/INVISIBLE) → onPause
// - LE2/j.v() → LE2/i.onPause（外部显式调用）
```

**结论**：背屏在 **AOD（息屏显示）模式下，WebView widget 仍保持可见**（HTML 主题自己画蓝屏待机 AOD 内容，WebView 一直显示），**框架不会 pause WebView → JS 定时器、requestAnimationFrame、CSS 动画、Chromium 合成器全部持续运行 → CPU/GPU 高负载 → 发热、卡顿、耗电**。

### 1.4 实测佐证

- 背屏进程常驻 `Chrome_*` 线程全家桶（VizWebView/InProcGp/ChildIOT/IOThread/ProcessL）
- 电池温度 40°C+（HTML 主题时）
- `WebViewScreenElement.doTick(J)` 每帧执行 `updateView()`（同步 View 位置/尺寸），即使不可见也在跑

---

## 二、主题侧省电优化（立即可用，无需 hook）

### 2.1 HTML JS 侧：AOD 时停止一切动画/定时器

```js
// ⭐ 核心：背屏框架会把 inAod 变量传给 HTML（#inAod=1/0）
// 用 maml.getDoubleByName('inAod') 检测 AOD 状态
var AOD = false;
var animTimer = null, clockTimer = null;

function setAodMode(on) {
  AOD = on;
  if (on) {
    // 进 AOD：停所有动画 & 高频定时器
    if (animTimer) { cancelAnimationFrame(animTimer); animTimer = null; }
    if (clockTimer) { clearInterval(clockTimer); clockTimer = null; }
    document.body.classList.add('aod-mode');  // CSS 停动画
    // 停 CSS 动画：.aod-mode *{animation:none!important;transition:none!important}
  } else {
    // 退出 AOD：恢复
    document.body.classList.remove('aod-mode');
    startClock(); startAnim();
  }
}

// 监听 inAod 变化（每 2 秒轮询一次，或由 MAML 命令触发）
setInterval(function(){
  var v = 0;
  try { v = window.maml.getDoubleByName('inAod') || 0; } catch(e){}
  if ((v===1) !== AOD) setAodMode(v===1);
}, 2000);
```

**CSS 侧**：
```css
/* AOD 模式下禁用一切动画 */
.aod-mode *{ animation:none !important; transition:none !important; }
.aod-mode { background:#000 !important; }
/* AOD 时把 Canvas/动态元素隐藏，只留极简时钟 */
.aod-mode .dynamic-elem { display:none !important; }
```

### 2.2 关键 JS 清理清单

| 耗电元凶 | 优化 |
|---|---|
| `setInterval(tick,1000)`（每秒时钟） | AOD 时 clearInterval，改 30s 一次 |
| `requestAnimationFrame` 动画循环 | AOD 时 cancelAnimationFrame |
| CSS `animation`/`transition` 持续动效 | `.aod-mode *{animation:none}` |
| `setInterval(aodRefresh,30000)` | 保留但 AOD 时减少到 60s |
| WebGL/Canvas 持续绘制 | AOD 时暂停绘制循环 |
| 外部图片/字体加载 | 避免 AOD 时发请求 |

### 2.3 manifest 侧优化

- `frameRate` 从 30 降到 **15**（HTML 主题基本不需要 30fps）
- `useVariableUpdater` 减少更新频率（`Battery` 够用，去掉 `DateTime.Second`）
- AOD 用 `<FrameRateCommand rate="0"/>`（MAML 侧完全停帧，但 HTML 的 WebView 仍会跑 JS——仍需 JS 侧配合）

---

## 三、Hook 优化方案（根治）

### 3.1 目标

**让 WebView 在 AOD 时真正暂停**（等价于 WebView.onPause + 停 JS/渲染），AOD 显示静态内容或由 MAML 层替代渲染。

### 3.2 Hook 点（已被反编译确认的类/方法）

| Hook 目标 | 方法 | hook 效果 |
|---|---|---|
| `LE2/i`（MamlWidget View） | `e(Z)` AOD 处理 | **在方法尾部追加：AOD=true 时调用** `this.onPause()`，AOD=false 时 `this.onResume()` |
| `LE2/w`（widget 基类） | `y(Z)` AOD 分发 | 统一在 AOD 时对 WebView 类 widget 调 onPause |
| `com.miui.maml.elements.WebViewScreenElement` | `pauseWebView(Z)` | 确保 AOD 时 WebView.onPause 真正调用 |
| `com.miui.maml.elements.web.MamlWebView` | `onPause`/`onResume` | 增强暂停（如 `setVisibility` 同步、暂停 JS） |
| `MainPanel` | `H()` / `w(ZZLA1/g;)` | 拦截 AOD 状态，强制 widget 暂停 |

### 3.3 推荐 hook 实现（核心）

```java
// Hook LE2/i.e(Z) —— AOD 时真正暂停 MamlView
XposedHelpers.findAndHookMethod(
    "E2.i", lpparam.classLoader,  // 混淆名，需用 findClass 探测
    "e", boolean.class,
    new XC_MethodHook() {
        @Override
        protected void afterHookedMethod(MethodHookParam param) {
            try {
                boolean inAod = (Boolean) param.args[0];
                Object view = param.thisObject;  // LE2/i = MamlView
                if (inAod) {
                    XposedHelpers.callMethod(view, "onPause");   // 停 MAML tick + WebView
                } else {
                    XposedHelpers.callMethod(view, "onResume");
                }
            } catch (Throwable t) { }
        }
    });
```

**注意**：
- `LE2/i`、`LE2/w`、`LE2/j` 是混淆类名，**不同版本可能不同**，hook 时要先 `findClass` 探测或用字符串特征（`MamlWidget`、`inAod`）定位。
- `onPause()` 会发 `pause` 命令给 HTML——**主题 JS 需响应 `pause` 命令停动画**（见下文 3.4）。

### 3.4 HTML 侧响应 pause 命令（配合 hook）

```js
// MAML pause 命令 → 停一切（hook 触发 onPause 时会发）
// 在 manifest 的 ExternalCommands 里加：
// <ExternalCommands><Command name="pause">...</Command></ExternalCommands>
// 或 HTML 里监听（WebView 不支持直接监听 MAML 命令，需靠变量/JS 桥）
// 推荐：hook 里 onPause 前先 putVariableString("webPaused","1")，HTML 轮询
```

---

## 四、与联网 Hook 联动（17 号文档）

- 联网 hook（17 号）：zygote 补 gid 3003 / packages.xml 补权限 / root 代理
- 发热 hook（本文）：AOD 时暂停 WebView
- **两者合一个模块**：`RearScreenBoost`（包名建议 `com.wmqc.rearscreenboost`）
  - Hook: `LE2/i.e`（AOD 暂停）+ zygote 网络补组 + 可选 WebView 增强（DOM storage、多窗口等）

---

## 五、立即行动的优先级

1. **主题 JS 侧优化**（零风险，立竿见影）：AOD 时 clearInterval + cancelAnimationFrame + CSS 停动画 → 能降 60-80% 耗电
2. **manifest frameRate=15 + AOD 变量检测**（零风险）
3. **写 `RearScreenBoost` hook 模块**（根治）：AOD 真正 pause WebView
4. **联网 hook**（17 号文档方案）

---
*作者：唯梦倾城 | 2026-09-15 | 与 12 号（WebView加载）、17 号（联网Hook）配套*
