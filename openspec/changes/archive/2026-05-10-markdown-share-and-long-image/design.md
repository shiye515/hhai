## Context

ArticleMarkdownView 当前使用 NavigationStack + 顶部导航栏的「完成」按钮关闭页面。Markdown 内容在 ScrollView 中渲染。项目没有任何 Photos 框架依赖，也没有分享功能。Info.plist 由 Xcode 管理（无独立文件）。

## Goals / Non-Goals

**Goals:**
- 底部固定工具栏，包含完成、分享、保存长图三个按钮
- 分享功能使用系统 UIActivityViewController，传递标题、URL 和正文摘要
- 保存长图将 Markdown 正文完整渲染为一张 UIImage 并存入相册
- 最小侵入性：不改变现有 Markdown 渲染管线

**Non-Goals:**
- 不分享图片/只分享文字摘要（长图是独立功能）
- 不做自定义分享面板
- 不做 PDF 导出

## Decisions

### 1. 底部工具栏用 `safeAreaInset(.bottom)` 而非 `toolbar(.bottomBar)`

`safeAreaInset` 直接在 ScrollView 底部插入固定视图，不占用 NavigationStack 的 toolbar 空间，与 `.refreshable` 等修饰符无冲突。布局可控性更好。

### 2. 分享用 `UIActivityViewController`

系统原生分享面板，零依赖。传递 `UIActivityItemSource` 实现，包含标题 + URL + 正文文本。

### 3. 长图渲染：离屏 VStack 测量高度 + `UIGraphicsImageRenderer`

将 Markdown 内容放入一个离屏 `VStack`，用 `sizeThatFits(.init(width: screenW, height: .infinity))` 获取完整高度，然后在 `UIGraphicsImageRenderer` 中用 `UIViewController` 的 `viewHierarchyInWindow` 或 `drawHierarchy(in:afterScreenUpdates:)` 渲染为 UIImage。这是 iOS 上最可靠的长图方案。

### 4. 相册写入用 `PHPhotoLibrary.shared().performChanges`

iOS 14+ 使用 `PHAssetCreationRequest` 写入图片，触发系统权限请求。失败时 toast 提示。

### 5. 权限文案（Info.plist）

`NSPhotoLibraryAddUsageDescription`: "用于保存文章长图到相册"。在 Xcode 项目的 Info.plist 配置页添加（项目无独立 Info.plist 文件）。

## Risks / Trade-offs

- **[超长文章可能内存峰值高]** — 长图渲染会将全部内容加载到内存中。→ 缓解：限制图片最大宽度为屏幕宽度，不额外放大；如果文章极长（>10000pt），考虑分段渲染但暂不实现。
- **[Markdown 中的代码块/表格在图片中可能截断]** — `sizeThatFits` 对 ScrollView 内部的横向滚动内容测量不准确。→ 缓解：渲染时使用无滚动的 VStack 布局，代码块用 `.fixedSize(horizontal: false, vertical: true)` 自动换行。
- **[深色模式图片颜色]** — 渲染时使用当前 colorScheme 的颜色。深色模式下图片背景为深色。→ 接受此行为，用户可切换浅色模式后保存。
