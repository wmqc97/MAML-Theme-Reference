# REARStore 组件提交参考文档

> 作者：唯梦倾城 | 仓库：EcoTag / EcoTag-Root  
> 最后更新：2026-08-30

---

## 一、widget_info.json 字段规范

### 1.1 基础字段（所有类型通用）

| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|
| `type` | string | ✅ | 组件类型：`card`（卡片）\| `wallpaper`（壁纸）\| `enhanced`（增强）\| `notification`（通知） |
| `name` | string | ✅ | 组件名称，不包含版本号后缀 |

> ✅ **`wallpaper` 壁纸类型的基础配置只需要 `type` 和 `name` 两个参数。**

### 1.2 壁纸 + JS 脚本采集（权限版专用）

权限版壁纸需要 UriRoute 脚本管理器采集硬件参数时，在基础字段上额外增加依赖与脚本注册：

```json
{
  "type": "wallpaper",
  "name": "能效标识（权限版）",
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

字段说明：

- `requirements.packages`：JS 脚本管理器包名，UriRoute 固定为 `com.uriroute`
- `postinstall.uri`：安装后自动注册脚本
  - `group` / `name` / `version`：脚本组、脚本名、版本号
  - `entry`：zip 包内的脚本文件名（对应 `uriroute.json` 的 `archiveKey`）

### 1.3 卡片类型（card）专属字段（壁纸不需要）

`card` 卡片类型还需要 `business_setup` / `card_setup` 等字段，`wallpaper` 壁纸类型自动忽略。

参考 **Deviceinfo-REAREye**（卡片类型 + UriRoute 脚本）：

```json
{
  "minVersion": 157,
  "name": "设备资讯",
  "business_setup": {
    "id": "uriroute_deviceinfo",
    "renameable": true
  },
  "card_setup": {
    "name": "设备资讯",
    "package": "hk.uwu.reareye",
    "priority": 500,
    "sticky": true,
    "renameable": true
  },
  "requirements": {
    "packages": ["com.uriroute"]
  },
  "postinstall": {
    "uri": "content://uriroute/install?group=REAREye&name=generality&version=1.0&reareyeUri={'mode':'store_id','id':'{id}','entry':'uriRoute.js'}"
  }
}
```

> ⚠️ 卡片类型的 `card_setup.package` 固定为 `hk.uwu.reareye`；壁纸类型不要填写 `card_setup`。
> 卡片类型用 `business_setup` 做业务标识，壁纸类型无需填写。

---

## 二、主题信息（description.xml）规范

> 🔔 **核心规则**：所有主题信息（标题、作者、介绍、版本说明等）统一写入 `description.xml`，
> `var_config.xml` 只承载可调参数（开关、文本、颜色等），不再承载主题信息。
> 后续创建的主题均采用 desc 格式显示主题信息。
> 🔄 **更新主题**：更新 `description.xml` 内的 `<version>` 版本号（如 `2.2 → 2.3`），
> 并同步更新 `<description>` 里的版本说明文字。

### 2.1 description.xml 字段说明

| 字段 | 说明 |
|------|------|
| `version` | 当前主题版本号（如 `2.2`）；**每次更新主题时同步更新此值** |
| `uiVersion` | UI 版本，固定 `12` |
| `author` / `designer` | 作者 / 设计者署名（唯梦倾城） |
| `title` | 主题显示名 |
| `description` | 主题介绍（含功能、版本历史） |
| `typeTag` | 类型绑定，权限版 `theme_bind:com.wmqc.uriroute`，普通主题留空 |
| `frame` | 帧率 |
| `editable` / `customEditLink` | 是否可编辑 / 是否允许自定义编辑链接 |
| `resourceType` | 资源类型：`wallpaper`（壁纸）/ `widgets`（卡片） |
| `authors` / `designers` / `titles` / `descriptions` | 多语言版本（以 `locale` 区分） |

### 2.2 resourceType 对应关系

| 主题类型 | resourceType | 说明 |
|---------|-------------|------|
| 壁纸主题 | `wallpaper` | 背屏壁纸 |
| 卡片 / 组件 | `widgets` | 背屏小组件 |

### 2.3 var_config.xml 减负原则

- **只保留**可调参数：`OnOff`（开关）、`Text`（文本）、`CustomColor`（颜色）等
- **不再承载**主题名称、作者、版本描述等信息
- 权限版无用户可调参数时可为空配置：`<WidgetConfig version="1"/>`

### 2.4 示例（EcoTag 主题版 description.xml 骨架）

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<theme>
  <version><![CDATA[2.3]]></version>
  <uiVersion>12</uiVersion>
  <author><![CDATA[唯梦倾城]]></author>
  <designer><![CDATA[唯梦倾城]]></designer>
  <title><![CDATA[能效标识_主题版]]></title>
  <description><![CDATA[主题介绍与版本说明...]]></description>
  <typeTag></typeTag>
  <frame>0</frame>
  <editable>true</editable>
  <customEditLink>true</customEditLink>
  <resourceType>wallpaper</resourceType>
  <authors><author locale="zh_CN"><![CDATA[唯梦倾城]]></author></authors>
  <titles><title locale="zh_CN"><![CDATA[能效标识_主题版]]></title></titles>
  <descriptions><description locale="zh_CN"><![CDATA[主题介绍与版本说明...]]></description></descriptions>
</theme>
```

---

## 三、本次两个版本的最终配置

### 3.1 主题版（EcoTag）

```json
{
  "type": "wallpaper",
  "name": "能效标识（主题版）"
}
```

- 纯 MAML 壁纸，无需 UriRoute 脚本
- 打包：`manifest.xml`、`var_config.xml`、`effect.png`、`strings/`

### 3.2 权限版（EcoTag-Root）

```json
{
  "type": "wallpaper",
  "name": "能效标识（权限版）",
  "requirements": {
    "packages": ["com.uriroute"]
  },
  "postinstall": {
    "uri": "content://uriroute/install?group=wmqc&name=spec&version=2&reareyeUri={'mode':'store_id','id':'{id}','entry':'spec.js'}"
  }
}
```

- `requirements.packages` 必须写 `com.uriroute`（JS 脚本管理器包名）
- `postinstall.entry` 指向 `spec.js`
- 打包：`manifest.xml`、`var_config.xml`、`effect.png`、`strings/`、`spec.js`、`uriroute.json`

---

## 四、服务器同步与版本更新机制

> ⚠️ **核心规则**：REAREye 服务器只通过 **GitHub Releases 包 + tag** 同步更新。
> 直接改仓库文件或 push 代码，服务器不会自动获取，用户也不会看到更新。

### 4.1 更新仓库必须同步三件事

| 项目 | 说明 |
|------|------|
| **GitHub Releases** | 创建新 Release 并上传最新 zip 资产（版本号递增） |
| **Git Tag** | 为本次更新打 tag（如 `v2.3`），与 Release 关联 |
| **desc 版本号** | 同步更新 `description.xml` 内 `<version>`（如 `2.2 → 2.3`） |

> 🔔 **触发时机**：用户说"更新仓库 / 不到仓库 / 需要更新"时，先确认是否需要发版。
> 若需发版，必须三件套齐全，否则服务器不会同步。

### 4.2 发版完整流程

1. 修改仓库文件（`widget_info.json`、`manifest.xml`、`README.md` 等）并推送
2. 打包最新 zip（仅必要文件，不包含 .git / README）
3. **验证 zip 可正常解压**（解压测试 + 确认必需文件完整，防止 multipart 头混入导致坏包）
4. 创建 git tag（如 `v2.3`）
5. 在 GitHub Releases 创建新版本（填 tag、标题、说明）
6. 上传最新 zip 资产到该 Release，**上传后必须回拉验证**：
   - 核对资产 `content_type` 应为 `application/zip`（不能是 `multipart/form-data`）
   - 核对资产 `size` 与本地 zip 完全一致
   - 从 Release 下载回刚上传的 zip，**再次解压测试通过**（必需文件完整、可正常打开）
7. 确认 `description.xml` 内 `<version>` 已同步更新

---

## 五、Issue 提交模板

### 5.1 标题格式

```
[Widget Submission] 组件名称（版本标识）
```

### 5.2 正文格式（必须严格按此模板）

```markdown
### Widget ID
ecotag

### Repository URL
https://github.com/wmqc97/EcoTag

### Widget Type
wallpaper
```

> ⚠️ 三个字段必须用 `### ` 开头，每行一个，否则会被机器人拒绝。

### 5.3 Widget Type 可选值

| 值 | 含义 |
|-----|------|
| `card` | 普通卡片 |
| `enhanced` | 增强卡片（替换官方卡片） |
| `notification` | 动态通知类卡片 |
| `wallpaper` | 壁纸类型 |

---

## 六、提交前检查清单

- [ ] 组件类型已确认（card / enhanced / notification / wallpaper）
- [ ] 壁纸类型 `widget_info.json` 基础配置只有 `type` + `name`
- [ ] 权限版需脚本时已补 `requirements` + `postinstall`
- [ ] `requirements.packages` 包名正确（UriRoute = `com.uriroute`）
- [ ] `postinstall.entry` 指向 zip 内实际存在的脚本文件
- [ ] 卡片类型的 `card_setup.package` = `hk.uwu.reareye`（壁纸不填）
- [ ] **主题信息已写入 `description.xml`**（标题 / 作者 / 介绍 / 版本说明）
- [ ] **`var_config.xml` 只保留可调参数**，无主题信息冗余
- [ ] **Git Tag 已创建**（版本号递增，如 v2.3）
- [ ] **GitHub Release 已创建并关联 tag**
- [ ] **Release zip 已打包并验证可正常解压**（必需文件完整，无 multipart 头混入）
- [ ] **上传后核对 Release 资产**：`content_type=application/zip`、`size` 与本地一致
- [ ] **上传后从 Release 回拉 zip 并再次解压验证通过**（确保服务器拿到的是好包）
- [ ] **desc `<version>` 已同步更新**（如 `2.2 → 2.3`）
- [ ] **README 预览图使用完整链接**（如 `https://raw.githubusercontent.com/用户/仓库/main/effect.png`），不能直接根目录引用（`effect.png`），否则 REAREye 无法加载
- [ ] Issue 正文三个 `###` 字段完整

---

## 七、常见问题

### Q1: Issue 被自动关闭？
- 正文必须严格按模板（三个 `###` 字段）
- Repository URL 必须是根地址
- Widget Type 只能四选一

### Q2: postinstall 的 entry 写什么？
- 指向 zip 内 `uriroute.json` 的 `archiveKey` 对应脚本文件名
- 权限版当前为 `spec.js`

### Q3: 安装提示"缺少应用"？
- 检查 `requirements.packages` 包名
- UriRoute 正确包名为 `com.uriroute`

### Q4: 主题版和权限版区别？
- 主题版：纯 MAML 壁纸，`widget_info.json` 只有 `type` + `name`
- 权限版：壁纸 + UriRoute 脚本，额外 `requirements` + `postinstall`

### Q5: 服务器为什么不更新？
- REAREye 服务器只通过 **GitHub Releases 包 + tag** 同步
- 直接 push 代码不会触发服务器更新
- 检查三件套：**Release 已上传 zip** + **tag 已创建** + **desc `<version>` 已更新**

### Q6: 发版更新流程？
1. 修改仓库文件并提交推送
2. 重新打包 zip（仅必要文件）
3. **验证 zip 可正常解压**（解压测试 + 必需文件完整）
4. 创建 git tag（版本号递增）
5. 在 GitHub Releases 创建新版本并关联 tag
6. 上传最新 zip 资产，**上传后回拉验证**（核对 `content_type=application/zip`、`size` 与本地一致，并下载回 zip 再次解压验证通过）
7. 同步更新 `description.xml` 内 `<version>`

---

## 八、技能要点（下次提交前必读）

> 🔔 **壁纸类型**：`widget_info.json` 只需 `type` + `name`。
> 若需 JS 脚本采集（权限版），再补 `requirements`（脚本管理器包名）+ `postinstall`（脚本注册）。
> 卡片类型才需要 `business_setup` / `card_setup`，壁纸不要填。
>
> 🚀 **发版三件套**：更新仓库 = **GitHub Release + Git Tag + desc `<version>` 版本号** 三件事必须一起做，
> 只 push 代码服务器不会同步更新。
>
> 📦 **上传前必检**：正式包 zip 打包后必须**解压测试通过**（必需文件完整、无 multipart 头混入）；
> 上传到 Release 后必须**回拉验证**：核对资产 `content_type=application/zip`、`size` 与本地 zip 完全一致，
> 并从 Release **下载回刚上传的 zip 再次解压验证通过**，否则视为坏包不可发布。
>
> 🖼️ **README 预览图**：必须使用**完整链接**（如 `https://raw.githubusercontent.com/wmqc97/TV-Test-Pattern/main/effect.png`），
> 不能直接根目录引用（如 `effect.png` 或 `./effect.png`），否则 REAREye 加载不了预览图。
>
> 🎨 **desc 格式**：主题信息（标题、作者、介绍、版本说明）一律写入 `description.xml`；
> `var_config.xml` 只留可调参数（开关 / 文本 / 颜色）。后续创建主题均按 desc 格式显示主题信息。