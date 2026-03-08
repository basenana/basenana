# Basenana

<p align="center">
  <img src="basenana/Assets.xcassets/AppIcon.appiconset/icon_16x16.png" alt="basenana logo" width="128" height="128">
</p>

<p align="center">
  <a href="https://github.com/nanafs/basenana/releases">
    <img src="https://img.shields.io/github/v/release/nanafs/basenana" alt="GitHub release">
  </a>
  <a href="https://github.com/nanafs/basenana/blob/main/LICENSE">
    <img src="https://img.shields.io/github/license/nanafs/basenana" alt="License">
  </a>
  <a href="https://github.com/nanafs/basenana">
    <img src="https://img.shields.io/github/stars/nanafs/basenana" alt="Stars">
  </a>
  <a href="https://github.com/nanafs/basenana/actions">
    <img src="https://img.shields.io/github/actions/workflow/status/nanafs/basenana" alt="Build">
  </a>
</p>

basenana 是 [nanafs](https://nanafs.com) 的 macOS 客户端，一个面向云上环境的、以文件为第一公民的 AI 驱动个人知识管理系统。

## 核心功能

### 📥 快速收藏

通过 URL Scheme (`basenana://capture`) 快速将网页抓取到 Inbox，支持从浏览器扩展一键收藏网页内容，保留原始网页的完整内容供稍后阅读。

### 📰 RSS 订阅

将 RSS/Atom 订阅源同步到 nanafs，支持：
- 自动定时抓取
- 自定义过滤规则 (CEL Pattern)
- 多格式存储 (HTML, XML, JSON, Markdown, WebArchive)

### 🤖 AI 助手 Friday

基于 LLM Agent 的方式与 nanafs 交互：
- 自然语言查询文档库
- 文档摘要与问答
- 引用文档进行对话

### 📖 文档阅读

多格式文档阅读支持：
- **PDF** - 完整 PDF 渲染
- **HTML** - 网页内容阅读
- **Markdown** - Markdown 渲染
- **WebArchive** - 离线网页存档

### 🔍 全文搜索

跨文档全文搜索，结果高亮显示，快速定位所需内容。

### ⚙️ 工作流自动化

灵活的工作流引擎，支持：
- RSS 自动抓取任务
- 定时执行任务
- 本地文件监控触发

## 截图预览

| Inbox | 文档阅读 |
|-------|----------|
| ![QuickInbox](docs/screenshots/QuickInbox.png) | ![DocumentRead](docs/screenshots/DocumentRead.png) |

| 未读文档 | RSS 订阅 |
|----------|----------|
| ![Unread](docs/screenshots/Unread.png) | ![NewRssGroup](docs/screenshots/NewRssGroup.png) |

## 技术栈

- **UI Framework**: SwiftUI
- **Architecture**: Clean Architecture
- **RSS Parsing**: [FeedKit](https://github.com/nmdias/FeedKit)
- **HTML Parsing**: [SwiftSoup](https://github.com/scinfu/SwiftSoup), [Fuzi](https://github.com/cezheng/Fuzi)
- **Layout**: [SwiftUIMasonry](https://github.com/Andrewmza/SwiftUIMasonry)
- **Dependency Injection**: [Swinject](https://github.com/Swinject/Swinject), [Factory](https://github.com/hmlongco/Factory)
- **Logging**: [SwiftyBeaver](https://github.com/SwiftyBeaver/SwiftyBeaver)

## 项目结构

```
basenana/
├── basenana/                   # App layer
│   ├── basenanaApp.swift       # App entry point
│   ├── DI/                     # Dependency injection
│   ├── Environment/            # Environment config
│   └── macOS/                  # macOS UI
├── Sources/
│   ├── Domain/                 # Domain layer (entities, use cases, protocols)
│   ├── Data/                   # Data layer (API clients, repositories)
│   ├── Feature/                # Feature layer (UI modules)
│   │   ├── Entry/              # Feed & capture
│   │   ├── Document/           # Document reading
│   │   └── Workflow/           # Workflow automation
│   └── Styleguide/             # Reusable UI components
└── Tests/                      # Unit tests
```

## 构建指南

### 前置要求

- macOS 14.0+
- Xcode 15.0+

### 构建步骤

```bash
# 1. 克隆项目
git clone https://github.com/nanafs/basenana.git
cd basenana

# 2. 生成 Xcode 项目
xcodegen generate

# 3. 在 Xcode 中打开
open basenana.xcodeproj

# 4. 构建项目
# Cmd + B 或
xcodebuild -project basenana.xcodeproj -scheme BasenanaApp -configuration Debug build
```

### 运行测试

```bash
xcodebuild test -scheme DomainTests
xcodebuild test -scheme DataTests
xcodebuild test -scheme FeatureTests
xcodebuild test -scheme StyleguideTests
```

## 依赖 nanafs 服务

basenana 需要配合 nanafs 服务使用。请访问 [nanafs.com](https://nanafs.com) 了解更多详情。

## License

Apache License 2.0 - see [LICENSE](LICENSE) for details.

---

<p align="center">
  Made with ❤️ by nanafs
</p>
