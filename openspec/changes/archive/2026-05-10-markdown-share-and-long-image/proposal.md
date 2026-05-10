## Why

ArticleMarkdownView 的完成按钮在顶部导航栏，单手操作不便。用户也无法将 AI 资讯文章分享给他人或保存为长图，限制了内容传播和使用场景。

## What Changes

- 完成按钮从顶部导航栏移至底部，与分享按钮一起固定在底部工具栏
- 底部新增分享按钮，调用系统 UIActivityViewController 分享文章标题、链接和正文
- 底部新增保存长图按钮，将 Markdown 全文渲染为一张图片并保存到相册
- 需要请求相册写入权限（iOS 14+ `PHPhotoLibrary` limited access）

## Capabilities

### New Capabilities
- `article-share`: 文章分享功能，通过系统分享面板分享标题、链接和正文
- `article-save-image`: 文章保存长图功能，将 Markdown 正文渲染为长图并保存到相册

### Modified Capabilities
- 无

## Impact

- `ArticleMarkdownView.swift` — 底部工具栏、分享和图片渲染逻辑
- 新增 Info.plist 键 `NSPhotoLibraryAddUsageDescription`（相册写入权限说明）
- 可能新增一个 helper view 负责将 Markdown 内容渲染为可截图的离屏视图
