## 1. Xcode 工程初始化

- [x] 1.1 创建 Xcode 项目结构（SwiftUI App lifecycle, iOS 17 target, bundle ID 配置）
- [x] 1.2 配置 Info.plist（App Transport Security, Safari Services 权限）
- [x] 1.3 创建项目目录结构：Models/, ViewModels/, Views/, Services/, DesignSystem/

## 2. 设计系统 (DesignSystem)

- [x] 2.1 实现颜色 token（DesignSystem.Color：primary #0066cc, ink, canvas, canvasParchment 等）
- [x] 2.2 实现字体 token（DesignSystem.Typography：displayHeadline, body, caption, bodyStrong 等 SF Pro 样式）
- [x] 2.3 实现间距 token（DesignSystem.Spacing：xxs 4, xs 8, sm 12, md 17, lg 24, xl 32, section 80）
- [x] 2.4 实现圆角 token（DesignSystem.Rounded：sm 8, lg 18, pill 9999）

## 3. 数据模型 (Models)

- [x] 3.1 创建 NewsItem SwiftData @Model（id, title, titleEn, url, source, publishedAt, summary, category）
- [x] 3.2 创建 APIResponse Decodable 结构体（ItemList: count, hasNext, nextCursor, items）
- [x] 3.3 创建 NewsItem Decodable 映射，与 SwiftData Model 双重用途

## 4. API 客户端 (Services)

- [x] 4.1 实现 APIClient 类（baseURL, URLSession async/await）
- [x] 4.2 实现 fetchItems(cursor:take:) 方法，GET /api/public/items?mode=selected
- [x] 4.3 实现 cursor 分页参数拼装与 URL 编码
- [x] 4.4 实现 503 重试逻辑（1 秒退避，最多 1 次重试）
- [x] 4.5 实现 ETag 缓存支持（存储/发送 If-None-Match，处理 304）
- [x] 4.6 定义 APIError 枚举（networkUnavailable, rateLimited, httpError, decodingError）

## 5. 本地缓存 (Services)

- [x] 5.1 创建 PersistenceController（SwiftData ModelContainer 初始化）
- [x] 5.2 实现 saveItems() 方法（upsert by id，去重）
- [x] 5.3 实现 loadCachedItems() 方法（按 publishedAt 降序返回）
- [x] 5.4 实现 pruneCache(maxItems: 500) 方法（删除最旧条目）
- [x] 5.5 实现 lastRefreshTime 读写（UserDefaults 存储时间戳）

## 6. ViewModel

- [x] 6.1 创建 NewsFeedViewModel（@Observable，管理 items 数组、isLoading、hasNext、error 状态）
- [x] 6.2 实现 loadInitial() 方法（先加载缓存，再发起 API 请求并更新缓存）
- [x] 6.3 实现 loadNextPage() 方法（cursor 分页，200ms 节流防重复）
- [x] 6.4 实现 refresh() 方法（下拉刷新，清空 cursor，重新请求第一页）
- [x] 6.5 实现缓存裁剪触发（fetch 后检查 >500 条则 prune）

## 7. 视图层 (Views)

- [x] 7.1 创建 NewsCardView（标题 bodyStrong、来源+时间 caption、摘要 body、按 DESIGN.md 排版）
- [x] 7.2 创建 NewsFeedView（ScrollView + LazyVStack，无限滚动检测，下拉刷新 .refreshable）
- [x] 7.3 实现加载状态视图（初始加载居中 spinner，底部加载 progress view）
- [x] 7.4 实现空状态视图（无数据时显示提示文字）
- [x] 7.5 实现 Safari 跳转（.sheet + SFSafariViewController，点击卡片触发）

## 8. App 入口与整合

- [x] 8.1 创建 App struct（@main，SwiftUI App lifecycle，注入 ModelContainer）
- [x] 8.2 创建 ContentView（NavigationView 包裹 NewsFeedView，配置导航栏样式）
- [x] 8.3 配置 App 图标和 Launch Screen（Assets.xcassets）
- [x] 8.4 设置 App 显示名称、版本号、部署目标 iOS 17.0

## 9. 收尾与上架准备

- [x] 9.1 添加网络请求日志（DEBUG 模式下 print 请求/响应）
- [ ] 9.2 测试离线场景（飞行模式下启动，验证缓存展示）
- [ ] 9.3 测试分页滚动（连续滚动加载多页，验证无重复）
- [ ] 9.4 配置 Archive scheme 与签名（准备 TestFlight/App Store 提交）
