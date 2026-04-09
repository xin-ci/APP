import SwiftUI

struct SettingsView: View {
    let onExport: () -> Void
    let onImport: () -> Void
    let statusMessage: String

    var body: some View {
        Form {
            Section("备份与恢复") {
                Button {
                    onExport()
                } label: {
                    Label("导出备份（JSON）", systemImage: "square.and.arrow.up")
                }

                Button {
                    onImport()
                } label: {
                    Label("导入备份（JSON）", systemImage: "square.and.arrow.down")
                }
            }

            Section("状态") {
                if statusMessage.isEmpty {
                    Text("暂无操作")
                        .foregroundStyle(.secondary)
                } else {
                    Text(statusMessage)
                        .font(.footnote)
                }
            }
        }
        .navigationTitle("设置")
    }
}
