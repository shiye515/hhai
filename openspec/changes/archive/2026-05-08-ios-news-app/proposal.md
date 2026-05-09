## Why

AI Hot 新闻站已有公开 API 提供精选 AI 新闻，但缺少原生 iOS 客户端。我们需要一个 SwiftUI 新闻阅读应用，让用户在 iPhone 上以时间线形式浏览精选 AI 新闻，支持离线优先加载，目标上架 App Store。

## What Changes

- 创建完整 Xcode 工程（Swift + SwiftUI），位于当前目录
- 接入 `aihot.virxact.com` 公开 API 的精选分类（`mode=selected`）
- 实现单视图无限滚动新闻列表，cursor 分页
- 离线优先：本地 SwiftData 缓存，启动时先展示本地数据再后台刷新
- 遵循 DESIGN.md 中的 Apple 设计规范（SF Pro 字体、Action Blue 主色、极简无阴影卡片风格）
- 支持下拉刷新、加载状态指示、错误处理
- 点击新闻条目跳转 Safari 打开原文

## Capabilities

### New Capabilities
- `news-feed`: 精选新闻列表视图，包含无限滚动分页、下拉刷新、离线数据加载
- `api-client`: aihot.virxact.com API 网络层，封装 `/api/public/items` 请求与 cursor 分页
- `local-cache`: SwiftData 本地持久化，缓存新闻条目，支持离线阅读
- `design-system`: 基于 DESIGN.md 的 SwiftUI 主题与组件系统（颜色、字体、间距 token）

### Modified Capabilities

（无已有 capability 需修改）

## Impact

- 新增完整 Xcode 项目结构，包含 SwiftUI App 入口、Model、ViewModel、View、Network 层
- 依赖：iOS 17+（SwiftData）、SwiftUI、SafariServices
- 网络依赖：`https://aihot.virxact.com/api/public/items?mode=selected`
- 无后端变更，仅消费现有公开 API
