## 1. Bottom Toolbar Setup

- [x] 1.1 Move "完成" button from navigation bar to a bottom `safeAreaInset` toolbar
- [x] 1.2 Remove top toolbar "完成" button from `NavigationStack`

## 2. Share Feature

- [x] 2.1 Add share button to bottom toolbar (SF Symbol: `square.and.arrow.up`)
- [x] 2.2 Implement share action presenting `UIActivityViewController` with article title, URL, and summary
- [x] 2.3 Handle share sheet dismissal gracefully

## 3. Save Long Image Feature

- [x] 3.1 Add "保存长图" button to bottom toolbar (SF Symbol: `arrow.down.doc`)
- [x] 3.2 Implement offscreen rendering of full Markdown content into `UIImage` using `UIGraphicsImageRenderer`
- [x] 3.3 Save rendered image to photo library via `PHPhotoLibrary.shared().performChanges`
- [x] 3.4 Add success toast after image save
- [x] 3.5 Add error alert on save failure

## 4. Info.plist & Permissions

- [x] 4.1 Add `NSPhotoLibraryAddUsageDescription` to Xcode project Info.plist with text "用于保存文章长图到相册"
