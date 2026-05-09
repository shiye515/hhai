## Context

AI Hot (aihot.virxact.com) 提供公开 API，无需认证，支持 cursor 分页获取精选 AI 新闻。当前没有 iOS 客户端。用户需要一个原生 SwiftUI 应用，在 iPhone 上以时间线形式浏览新闻，支持离线阅读。

DESIGN.md 定义了 Apple 风格设计系统：SF Pro 字体、Action Blue (#0066cc) 主色、极简无阴影卡片、pill 形状按钮。本次 iOS 实现需遵循该设计语言。

## Goals / Non-Goals

**Goals:**
- 单视图新闻列表，无限滚动，cursor 分页
- 离线优先：SwiftData 本地缓存，启动时立即展示缓存数据，后台静默刷新
- 遵循 DESIGN.md 设计规范的原生 SwiftUI 界面
- 点击新闻跳转 Safari 打开原文
- 支持下拉刷新与加载状态
- 可上架 App Store 的完整 Xcode 工程

**Non-Goals:**
- 不做用户认证/登录
- 不做推送通知
- 不做搜索功能（后续迭代）
- 不做日报/每日报告视图（仅 items API）
- 不做图片展示（API 不返回图片字段）
- 不做 iPad 适配（仅 iPhone 竖屏）

## Decisions

### 1. 数据持久化：SwiftData vs Core Data

**选择**: SwiftData

**理由**: iOS 17+ 原生 ORM，声明式 API 与 SwiftUI 深度集成，代码量远少于 Core Data。最低部署目标设为 iOS 17，覆盖 2023 年 9 月后所有设备。

**替代方案**: Core Data 更成熟但样板代码多；UserDefaults/文件缓存不支持结构化查询。

### 2. 网络层：URLSession vs Alamofire

**选择**: 原生 URLSession + async/await

**理由**: 零外部依赖，Swift Concurrency 原生支持，满足简单 GET 请求需求。API 无认证、无复杂重试逻辑，不需要第三方库。

**替代方案**: Alamofire 功能丰富但对本项目过度工程化。

### 3. 架构模式：MVVM

**选择**: MVVM（Model-View-ViewModel）

**理由**: SwiftUI 标准模式。ViewModel 用 `@Observable` 宏（iOS 17+），管理网络请求与本地数据源，View 纯声明式。

### 4. 分页策略

**选择**: 基于 cursor 的无限滚动，使用 `.task` modifier 在 ScrollView 底部触发加载。

**理由**: API 原生支持 cursor 分页（`nextCursor`），无需自行管理页码。列表底部出现时请求下一页，200ms 节流避免重复请求。

### 5. 离线策略

**选择**: 启动时立即从 SwiftData 加载缓存并展示，同时发起网络请求。网络成功后更新缓存并刷新 UI。网络失败时保留缓存数据，静默吞掉错误（不弹 alert）。

**理由**: 离线优先保证启动即有内容，后台刷新保持数据新鲜。新闻类应用不适合阻塞式加载。

### 6. 设计系统实现

**选择**: 将 DESIGN.md 的 token 映射为 Swift 枚举/结构体（Color、Font、Spacing），通过 SwiftUI extension 使用。

**理由**: 保持设计 token 集中管理，View 层通过 `DesignSystem.Color.primary` 等语义化引用，便于后续主题切换。

### 7. 最低部署目标

**选择**: iOS 17.0

**理由**: SwiftData 和 `@Observable` 宏均要求 iOS 17。iOS 17 覆盖 iPhone XS 及更新设备，市场覆盖率足够。

## Risks / Trade-offs

- **[API 无图片]** → 新闻卡片纯文本展示，视觉吸引力有限。缓解：通过精心排版和 DESIGN.md 设计语言弥补。
- **[7 天数据窗口]** → API 的 `since` 参数硬限制最多 7 天历史。缓解：本地缓存可保留更久，但新安装只能获取最近 7 天。
- **[Rate Limit 600/min]** → 单用户正常使用远低于此限制，但快速连续刷新可能触发 503。缓解：请求间加 200ms 延迟，错误时退避。
- **[SwiftData iOS 17 最低]** → 排除 iOS 16 及以下设备。缓解：iOS 17 市场份额已足够大，且 SwiftData 开发效率显著优于 Core Data。
