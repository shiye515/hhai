## Why

当前新闻流采用扁平列表布局，缺乏时间维度的视觉表达。引入时间线设计可以让用户直观感知新闻的时间分布和节奏，同时通过极简悬浮卡片提升阅读体验和视觉层次感。

## What Changes

- 重构 NewsFeedView 主布局：左侧垂直时间线 + 右侧新闻卡片并排
- 时间线上每个卡片对应一个圆点，点旁标注小时:分钟
- 新闻卡片采用极简悬浮风格：无边框、微妙阴影、充足留白
- 卡片与时间线之间通过连接线关联
- 时间线颜色、字体、间距等遵循 DESIGN.md 规范

## Capabilities

### New Capabilities
- `timeline-layout`: 时间线布局系统，包括垂直时间线轴、时间标注、卡片连接点和响应式适配

### Modified Capabilities
- `news-feed`: 新闻流主视图从扁平列表改为时间线布局，卡片视觉风格从标准列表项改为悬浮极简卡片

## Impact

- `NewsFeedView.swift`: 重写主布局结构
- `NewsCardView.swift`: 调整卡片视觉风格为悬浮极简设计
- 新增时间线相关视图组件（TimelineView, TimelineDot, TimeLabel）
- 设计系统 token 无变化，复用现有色彩/字体/间距
