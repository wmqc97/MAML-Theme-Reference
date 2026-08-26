# REARStore 组件提交参考文档

> 作者：唯梦倾城 | 仓库：EcoTag / EcoTag-Root  
> 最后更新：2026-08-21

---

## 一、widget_info.json 完整字段说明

### 1.1 基础字段

| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|
| `type` | string | ✅ | 组件类型：`widget`（卡片）\| `wallpaper`（壁纸）\| `enhanced`（增强）\| `notification`（通知） |
| `name` | string | ✅ | 组件名称，不包含版本号后缀 |
| `minVersion` | int | ❌ | 最低 REAREye 版本要求 |
| `maxVersion` | int | ❌ | 最高 REAREye 版本支持 |

### 1.2 business_setup（业务标识）

```json
"business_setup": {
  "id": "ecotag",        // 唯一业务 ID，与仓库 widget_info.json 中的 id 一致
  "renameable": false    // 是否允许用户重命名
}
```

### 1.3 card_setup（卡片设置，可选）

```json
"card_setup": {
  "name": "能效标识",           // 卡片显示名称
  "package": "hk.uwu.reareye",  // 固定值
  "priority": 500,              // 优先级
  "sticky": true,               // 是否常驻
  "renameable": false           // 是否允许重命名
}
```

### 1.4 scene_setup（场景匹配，仅 notification 类型可用）

```json
"scene_setup": {
  "scene": "messageCenter",                    // 场景名，支持正则前缀 "re:" 或 "regex:"
  "pkg": "com.example.app"                     // 包名，同样支持正则
}
```

### 1.5 requirements（安装条件，可选）

```json
"requirements": {
  "packages": ["com.Badnng.moe"],    // 必须已安装的应用包名列表
  "configs": {                       // 必须满足的配置状态
    "enable_allow_rear_focus_notices": true,
    "lyric_display_mode": ">= 1",
    "background_whitelist_apps": "== com.miHoYo.Nap"
  }
}
```

### 1.6 postinstall（安装后执行，可选）

```json
// {id} = store id, {business} = business id, {card} = card id
"postinstall": {
  "uri": "content://uriroute/install?group=REAREye&name=generality&version=1.0&reareyeUri={'mode':'store_id','id':'{id}','entry':'uriRoute.js'}"
}
```

> **注意**：permissions 版需要 postinstall 来注册 UriRoute 脚本，主题版不需要。

---

## 二、本次两个版本的配置对比

### 2.1 主题版（EcoTag）widget_info.json

```json
{
  "type": "wallpaper",
  "name": "能效标识（主题版）",
  "id": "ecotag"
}
```

- 无 `postinstall`（不需要 UriRoute 脚本）
- 无 `business_setup` / `card_setup`（壁纸类型可选）
- 打包文件：`manifest.xml`、`var_config.xml`、`effect.png`、`strings/strings_zh_CN.xml`

### 2.2 权限版（EcoTag-Root）widget_info.json

```json
{
  "type": "wallpaper",
  "minVersion": 99,
  "name": "能效标识（权限版）",
  "business_setup": {
    "id": "ecotag_root",
    "renameable": true
  },
  "requirements": {
    "packages": [
      "com.uriroute"
    ]
  },
  "postinstall": {
    "uri": "content://uriroute/install?group=wmqc&name=spec&version=2&reareyeUri={'mode':'store_id','id':'{id}','entry':'spec.js'}"
  }
}
```

- ⚠️ **`requirements.packages` 必须写 `com.uriroute`**（不是 `com.example.uriroute`），否则安装时会提示缺少依赖
- `postinstall` 通过 `com.uriroute` 中间件注册 UriRoute 脚本，`entry` 指向 `spec.js`（对应 uriroute.json 中的 archiveKey）
- 打包文件：`manifest.xml`、`var_config.xml`、`effect.png`、`strings/strings_zh_CN.xml`、`spec.js`、`uriroute.json`

---

## 三、Issue 提交模板

### 3.1 标题格式

```
[Widget Submission] 组件名称（版本标识）
```

示例：
- `[Widget Submission] 能效标识（主题版）`
- `[Widget Submission] 能效标识（权限版）`

### 3.2 正文格式（必须严格按此模板）

```markdown
### Widget ID
ecotag

### Repository URL
https://github.com/wmqc97/EcoTag

### Widget Type
wallpaper
```

> ⚠️ **重要**：三个字段必须用 `### ` 开头，每行一个，否则会被自动关闭机器人拒绝。

### 3.3 Widget Type 可选值

| 值 | 含义 |
|-----|------|
| `card` | 普通卡片 |
| `enhanced` | 增强卡片（替换官方卡片） |
| `notification` | 动态通知类卡片 |
| `wallpaper` | 壁纸类型 |

---

## 四、提交前检查清单

- [ ] **卡片类型已确认**（询问用户选择 card/enhanced/notification/wallpaper）
- [ ] `widget_info.json` 的 `type` 字段与提交类型一致
- [ ] 仓库 URL 格式：`https://github.com/wmqc97/<repo>`
- [ ] Widget ID 与仓库 `widget_info.json` 中的 `id` 一致
- [ ] 权限版如有 `postinstall`，`entry` 指向 zip 包中实际存在的脚本文件
- [ ] Release 包已打包并上传最新 zip 资产
- [ ] Issue 正文三个 `###` 字段完整

---

## 五、常见问题

### Q1: Issue 被自动关闭？
- 检查正文格式是否严格按模板（三个 `###` 字段）
- Repository URL 必须是 `https://github.com/<owner>/<repo>` 根地址
- Widget Type 只能是四个合法值之一

### Q2: postinstall 的 entry 写什么？
- 指向 zip 包中 `uriroute.json` 的 `archiveKey` 字段对应的脚本文件名
- 权限版当前为 `spec.js`（uriroute.json 中 `archiveKey: "spec.js"`）

### Q5: 安装时提示"缺少应用：com.example.xxx"？
- 检查 `requirements.packages` 中的包名是否正确
- 示例包名 `com.example.uriroute` 是模板占位符，实际依赖应写 `com.uriroute`
- 确认设备上已安装该应用：`pm list packages | grep <包名>`

### Q3: 主题版和权限版有什么区别？
- 主题版：纯 MAML 主题文件，无权限要求
- 权限版：含 UriRoute 脚本，通过 postinstall 自动注册，可获取系统信息

### Q4: release 包更新流程？
1. 修改仓库文件并 `git commit` + `git push`
2. 重新打包 zip（只包含必要文件，不包含 .git / README 等）
3. 删除旧 Release 资产，上传新 zip

---

## 六、下次提交前必读

> 🔔 **提交前必须确认**：向用户询问本次组件的卡片类型（card / enhanced / notification / wallpaper），
> 不可自行决定，因为类型选择会影响组件在 REAREye 中的展示方式和功能注册。