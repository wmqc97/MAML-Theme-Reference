# 动画系统

> 来源：https://zhuti.designer.xiaomi.com/docs/grammar/

---

## 变量动画（VariableAnimation）

用一个特殊的 number 类型变量来定义动画：

| 属性 | 值 | 释义 |
|------|-----|------|
| `initPause` | true/false | true 时无命令执行时停在初始态 |
| `loop` | true/false | 是否循环，默认 true；false 时播放一次就停 |
| `time` | 数字 | 毫秒时间，不支持表达式（绝对时间） |
| `dtime` | 数字或表达式 | 毫秒时间，支持表达式（相对时间，相对上一个的时间） |

```xml
<Var name="ani">
    <VariableAnimation loop="false" initPause="true">
        <AniFrame value="100" time="0" easeType="SineEaseOut"/>
        <AniFrame value="500" time="500"/>
    </VariableAnimation>
</Var>

<!-- 绑定动画变量到元素属性 -->
<Rectangle name="rect" x="#ani" y="100" w="100" h="100" fillColor="#ff0000"/>
```

### dtime 与 time 的区别

```xml
<!-- time：绝对时间（从动画开始计算） -->
<AniFrame value="0"   time="0"/>
<AniFrame value="100" time="500"/>   <!-- 第500ms时值为100 -->
<AniFrame value="200" time="1000"/>  <!-- 第1000ms时值为200 -->

<!-- dtime：相对时间（相对上一帧的时间） -->
<AniFrame value="0"   dtime="0"/>
<AniFrame value="100" dtime="500"/>  <!-- 距上一帧500ms后值为100 -->
<AniFrame value="200" dtime="500"/>  <!-- 再过500ms后值为200 -->
```

---

## 数组动画

```xml
<Var name="aniArr" values="0,0,0" type="number[]">
    <VariableAnimation loop="true">
        <AniFrame value="0"   time="0"/>
        <AniFrame value="100" time="500"/>
    </VariableAnimation>
</Var>
```

---

## 元素动画

所有元素都支持动画（位置、大小、旋转、透明度、图片源）。各种动画相互独立，各自循环播放。

```xml
<Image src="ball.png" x="0" y="100" w="100" h="100">
    <!-- 位置动画：1秒从最左端到最右端，停留1秒 -->
    <PositionAnimation loop="true">
        <PosFrame x="0"              time="0"/>
        <PosFrame x="#screen_width"  time="1000"/>
        <PosFrame x="#screen_width"  time="2000"/>
    </PositionAnimation>
    <!-- 透明度动画 -->
    <AlphaAnimation loop="true">
        <AlphaFrame alpha="175" time="0"/>
        <AlphaFrame alpha="175" time="1000"/>
        <AlphaFrame alpha="255" time="1500"/>
        <AlphaFrame alpha="0"   time="2000"/>
    </AlphaAnimation>
</Image>
```

---

## 动画控制命令（AnimationCommand）

| 属性 | 释义 |
|------|------|
| `target` | 控制的动画目标名 |
| `command` | 播放命令 |
| `Index` | 为数组动画添加索引 |
| `targetIndex` | 数组动画索引角标 |
| `tag` | 用于一个元素预置多个动画效果，用 tags 来选择性播放 |

| 命令示例 | 释义 |
|---------|------|
| `play` | 从头播放 |
| `pause` | 暂停 |
| `resume` | 从当前位置继续播放 |
| `play(100)` | 从 time=100ms 开始播放到结束，不循环 |
| `play(100, 500)` | 从 time=100ms 播放到 500ms，停止 |
| `play(100, 500, 1)` | 从 time=100ms 播放到 500ms，循环播放 |

```xml
<Button x="0" y="0" w="#screen_width" h="#screen_height">
    <Triggers>
        <Trigger action="down">
            <AnimationCommand target="ani" command="play(0,300)"/>
        </Trigger>
        <Trigger action="up">
            <AnimationCommand target="ani" command="play(300,600)"/>
        </Trigger>
    </Triggers>
</Button>
```

---

## 关键帧动画（MIUI13新增）

### AnimState（动画状态）

预先定义元素需要到达的状态：

| 属性 | 说明 | 备注 |
|------|------|------|
| `name` | 状态名（必填） | String |
| `x, y` | 坐标 | 数字表达式 |
| `w, h` | 宽高 | 数字表达式 |
| `rotation` | 旋转角度 | 数字表达式 |
| `alpha` | 透明度 | 0~255 |
| `rotationX/Y/Z` | 各轴旋转角度 | 数字表达式 |
| `scaleX, scaleY` | 各轴缩放比例 | 数字表达式 |
| `tintColor` | 染色颜色 | 如 `0xffffffff` |
| `pivotX/Y/Z` | 旋转中心 | 数字表达式 |

特殊属性（特定元素独有）：

| 属性 | 说明 |
|------|------|
| `r` | 圆的半径（圆形独有） |
| `textSize` | 文字大小（文字独有） |
| `textColor` | 文字颜色（文字独有，如 `0xffffffff`） |
| `textShadowColor` | 文字阴影颜色 |
| `fillColor` | 填充颜色（几何图形独有，如 `0xffffffff`） |
| `strokeColor` | 描边颜色（几何图形独有） |
| `cornerRadiusX/Y` | 矩形圆角（圆角矩形独有） |
| `strokeWeight` | 描边宽度（几何图形独有） |

> 颜色值相关属性必须用 `0xffffffff` 方式定义，不能使用 `#ffffffff`

### AnimConfig（动画曲线配置）

| 属性 | 说明 |
|------|------|
| `name` | 配置名称 |
| `delay` | 延时（数字表达式） |
| `ease` | 曲线，格式 `"曲线类型,参数1,参数2"` |
| `fromSpeed` | 初始速度 |
| `property` | 指定属性，如 `property="'x','y'"` |
| `onBegin` | 动画开始时的回调函数名 |
| `onComplete` | 动画完成时的回调函数名 |
| `onUpdate` | 动画进行中的回调函数名 |

### 曲线类型

| 曲线名称 | 类型编号 | 使用说明 |
|---------|---------|---------|
| `friction` | -4 | `ease="-4,阻力摩擦系数(0~1)"` |
| `accelerate` | -3 | `ease="-3,加速度(Kpixels/s^2)"` |
| `spring_phy` | -2 | `ease="-2,阻尼,响应"` 保留运动状态 |
| `duration` | -1 | `ease="-1,持续时间(ms)"` |
| `spring` | 0 | `ease="0,阻尼,响应"` 保留运动状态 |
| `linear` | 1 | `ease="1,持续时间(ms)"` |
| `quadIn/Out/InOut` | 2/3/4 | `ease="2,持续时间(ms)"` |
| `cubicIn/Out/InOut` | 5/6/7 | `ease="5,持续时间(ms)"` |
| `quartIn/Out/InOut` | 8/9/10 | `ease="8,持续时间(ms)"` |
| `quintIn/Out/InOut` | 11/12/13 | `ease="11,持续时间(ms)"` |
| `sinIn/Out/InOut` | 14/15/16 | `ease="14,持续时间(ms)"` |
| `expoIn/Out/InOut` | 17/18/19 | `ease="17,持续时间(ms)"` |

### 关键帧动画播放（FolmeCommand）

```xml
<!-- 将元素从当前状态运动到状态A，支持打断 -->
<FolmeCommand target="test" command="to" states="'stateA'" config="'configA'" />

<!-- 将元素从当前状态直接变为状态A（无动画） -->
<FolmeCommand target="test" command="setTo" states="'stateA'" />

<!-- 将元素从状态A运动到状态B -->
<FolmeCommand target="test" command="fromTo" states="'stateA', 'stateB'" config="'configA'"/>

<!-- 结束当前动画 -->
<FolmeCommand target="test" command="cancel" />

<!-- 结束当前动画的部分属性 -->
<FolmeCommand target="test" command="cancel" params="'x', 'y'"/>
```

### 完整示例

```xml
<!-- 定义状态 -->
<FolmeState name="stateA" x="100" y="200" alpha="255"/>
<FolmeState name="stateB" x="500" y="200" alpha="128"/>

<!-- 定义动画曲线 -->
<FolmeConfig name="configA" ease="-2, 0.5, 0.9">
    <Special property="'alpha'" ease="1, 300"/>
</FolmeConfig>

<!-- 定义元素 -->
<Rectangle name="test" x="100" y="200" w="100" h="100" fillColor="#ff0000" folmeMode="true"/>

<!-- 触发动画 -->
<Button x="0" y="0" w="#screen_width" h="#screen_height">
    <Triggers>
        <Trigger action="up">
            <FolmeCommand target="test" command="to" states="'stateB'" config="'configA'"/>
        </Trigger>
    </Triggers>
</Button>
```

---

## 缓动函数（easeType）

在 VariableAnimation 的 AniFrame 中使用 `easeType` 属性：

```xml
<AniFrame value="100" time="0" easeType="SineEaseOut"/>
<AniFrame value="500" time="500" easeType="BackEaseIn(1.5)"/>
<AniFrame value="300" time="1000" easeType="ElasticEase(2,3)"/>
```

也可以用 `easeExp` 自定义缓动函数（引用内置变量 `#__ratio`）：

```xml
<!-- QuadEaseIn 等效写法 -->
<AniFrame value="500" time="500" easeExp="#__ratio*#__ratio"/>
```

> 当有 `easeExp` 时，`easeType` 不起作用。属性作用于从该帧到下一帧，最后一帧没用。
