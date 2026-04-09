import SwiftUI

struct ItemDetailView: View {
    let item: ItemNode
    let onDelete: () -> Void
    let onIncrease: () -> Void

    var body: some View {
        Form {
            Section("基础信息") {
                LabeledContent("名称", value: item.name)
                LabeledContent("数量", value: "\(item.quantity)")
                LabeledContent("标签", value: item.tags.joined(separator: ", "))
            }

            Section("操作") {
                Button("数量 +1", action: onIncrease)
                Button("删除物品", role: .destructive, action: onDelete)
            }
        }
        .navigationTitle("物品详情")
    }
}
