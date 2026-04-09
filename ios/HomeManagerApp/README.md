# HomeManagerApp SwiftUI 骨架

这是一个可继续扩展成 App Store 上架版本的 SwiftUI 骨架，当前已实现：

- 树状空间模型（空间可无限新增子空间）
- 空间 Breadcrumb 导航
- 当前空间的子空间网格显示
- 当前空间物品列表显示
- 新增子空间 / 新增物品
- 搜索当前空间下的子空间与物品
- 物品详情页（数量调整、删除）
- 空间删除（递归删除子空间与其物品）
- 基础防循环移动校验（数据层）

## 目录

- `HomeManagerApp.swift`: 应用入口
- `Models/NodeModels.swift`: 空间/物品数据模型
- `Store/HomeStore.swift`: 内存数据仓库与核心用例
- `ViewModels/HomeViewModel.swift`: 页面状态与操作
- `Views/HomeTreeView.swift`: 首页可视化操作界面
- `Views/ItemDetailView.swift`: 物品详情页

## 已覆盖的核心用例

1. 任意空间下新增子空间
2. 任意空间下新增物品
3. 按路径逐层钻取
4. 当前层级搜索空间/物品
5. 删除空间时递归清理子空间与物品
6. 物品详情页快捷操作

## 下一步建议

1. 将 `HomeStore` 从内存存储替换为 SwiftData/Core Data
2. 添加 `SpaceDetailView` 与编辑弹窗
3. 加入拖拽排序、拖拽移动、批量操作
4. 接入 CloudKit 同步与冲突处理
5. 完成隐私政策与删除账号流程页面（若引入账号）

## Core 逻辑测试（Linux/macOS 可跑）

为了支持在非 Apple UI 环境中做自动化验证，仓库新增了 `ios/HomeManagerCore` Swift Package，包含纯数据结构与树操作引擎，并带有 XCTest：

- `addSpace` / `addItem`
- `breadcrumb`
- `moveSpace` 防环
- `deleteSpace` 递归删除
- scoped search
- 数量最小值保护

执行：

```bash
cd ios/HomeManagerCore
swift test
```
