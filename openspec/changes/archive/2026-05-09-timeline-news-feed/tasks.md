## 1. 时间线视图组件

- [x] 1.1 创建 TimelineView 组件（HStack 布局，左侧 60pt 时间线列 + 右侧弹性卡片列）
- [x] 1.2 创建 TimelineDotView 组件（8pt 实心圆，`{colors.primary}` 颜色）
- [x] 1.3 创建 TimeLabelView 组件（HH:mm 格式，`{typography.caption}` 样式，位于圆点右侧）
- [x] 1.4 实现垂直时间线轴（2pt 宽，`{colors.hairline}` 颜色，从首项延伸至末项）

## 2. 悬浮卡片样式

- [x] 2.1 重构 NewsCardView 为悬浮极简风格（无边框、`{colors.canvas}` 背景、`{rounded.lg}` 圆角、`{spacing.lg}` 内边距）
- [x] 2.2 添加卡片阴影（`rgba(0, 0, 0, 0.06) 0 2px 12px`）
- [x] 2.3 调整卡片间距为 `{spacing.md}` (17px) 防止阴影重叠

## 3. 布局集成

- [x] 3.1 重构 NewsFeedView 使用 TimelineView 替代原有 LazyVStack 布局
- [x] 3.2 实现圆点与卡片顶部对齐（alignment: .top）
- [x] 3.3 确保时间线轴在滚动时保持正确延伸

## 4. 响应式适配

- [x] 4.1 添加屏幕宽度检测（< 736pt 为 compact 模式）
- [x] 4.2 compact 模式下隐藏时间线列，卡片全宽显示
- [x] 4.3 保留悬浮卡片风格在 compact 模式下的一致性

## 5. 功能验证

- [ ] 5.1 验证无限滚动在时间线布局下正常工作
- [ ] 5.2 验证下拉刷新在时间线布局下正常工作
- [ ] 5.3 验证 Safari 跳转在新卡片样式下正常工作
