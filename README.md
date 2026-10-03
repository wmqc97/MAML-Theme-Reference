# MAML 主题语法参考

小米手机背屏（后盖屏）MAML 主题开发参考资料。

## 目录

| 路径 | 说明 |
|------|------|
| **`skills/maml-backscreen-theme/`** | ⭐ 标准 Agent Skill 结构，推荐给 AI 助手使用 |
| `自建示例参考文档/` | 实战文档原稿（历史路径，内容与 skill 的 references 同源） |
| `maml官方语法示例/` | 小米官方 MAML 语法镜像 |

## skills/maml-backscreen-theme

可直接导入 AI 助手（Agent Skills）的技能包：

```
maml-backscreen-theme/
├── SKILL.md                    # 技能入口：何时使用、工作流程、核心模式速查
├── references/                 # 53 篇详细文档
│   ├── 00-索引.md              # 关键词 → 文件映射（优先读）
│   ├── 基础语法/               # 变量、UI、命令、动画
│   ├── 实战技巧/               # 机型适配、AOD、WebView、踩坑、媒体歌词
│   ├── 进阶主题/               # GL、摄像头、日程电池、官方主题解析
│   ├── 配置规范/               # var_config、description.xml
│   └── 官方语法/               # 官方 MAML 语法镜像
└── scripts/
    └── sync_github.sh          # GitHub API 同步脚本（设备无 git 时用）
```

### 覆盖内容

- **WebView 加载 HTML 到背屏**：`<WebView>` 元素、`local="true"`、web/ 目录结构、黑屏根因
- **摄像头避让**：左侧挖孔 296px ≈ 31vw，四角圆角 101px
- **MediaSession 媒体信息与歌词**：`<MusicControl>` 读歌名/歌手/进度；歌词的两条路（车机版广播 / 手机版蓝牙歌词存在 `title` 里滚动）与判别算法
- **MAML ↔ HTML 双向通信**：`uriExp` 传参、`WebViewCommand runjs`、`window.maml.getXxx` / `doAction`
- **AOD 息屏**：`__setAod` 接口、HTML 侧实现、每分钟刷新
- **数据绑定**：`BroadcastBinder` / `ContentProviderBinder`（含"必须放 `<VariableBinders>` 容器"的坑）
- **打包与装机**：`.zip` 规范、Hook 直装、md5 校验、leveldb 调试法

## 使用方式

1. **AI 助手**：把 `skills/maml-backscreen-theme/` 作为技能导入，或让 AI 读取 `SKILL.md` + `references/00-索引.md`
2. **手动查阅**：从 `references/00-索引.md` 按关键词定位到具体文档

## 环境

- 目标机型：小米 17 Pro / Pro Max 背屏（976×596）
- 面向 HyperOS / MIUI 的 MAML 引擎
- 同步脚本依赖设备自带 `curl` / `base64` / `awk` / `od`（无需 git）

---
作者：唯梦倾城
