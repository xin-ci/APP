import Foundation

@MainActor
final class HomeViewModel: ObservableObject {
    @Published var selectedSpaceID: UUID
    @Published var newSpaceName: String = ""
    @Published var newItemName: String = ""
    @Published var searchText: String = ""
    @Published var snapshotStatusMessage: String = ""

    private let store: HomeStore

    init(store: HomeStore) {
        self.store = store
        self.selectedSpaceID = store.rootID
    }

    var currentBreadcrumb: [SpaceNode] {
        store.breadcrumb(for: selectedSpaceID)
    }

    var childSpaces: [SpaceNode] {
        store.childrenSpaces(of: selectedSpaceID)
    }

    var currentItems: [ItemNode] {
        store.items(in: selectedSpaceID)
    }

    var searchSpaces: [SpaceNode] {
        store.search(keyword: searchText, under: selectedSpaceID).0
    }

    var searchItems: [ItemNode] {
        store.search(keyword: searchText, under: selectedSpaceID).1
    }

    var isSearching: Bool {
        !searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    func goToSpace(_ id: UUID) {
        selectedSpaceID = id
    }

    func createSpace() {
        let name = newSpaceName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !name.isEmpty else { return }
        store.addSpace(name: name, parentID: selectedSpaceID)
        newSpaceName = ""
    }

    func createItem() {
        let name = newItemName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !name.isEmpty else { return }
        store.addItem(name: name, spaceID: selectedSpaceID)
        newItemName = ""
    }

    func deleteSpace(_ id: UUID) {
        store.deleteSpace(id)
        if store.space(id: selectedSpaceID) == nil {
            selectedSpaceID = store.rootID
        }
    }

    func deleteItem(_ id: UUID) {
        store.deleteItem(id)
    }

    func incrementItem(_ id: UUID, current: Int) {
        store.updateItemQuantity(id, quantity: current + 1)
    }


    func exportSnapshot() {
        do {
            let url = try store.exportSnapshot()
            snapshotStatusMessage = "备份已导出：\(url.path)"
        } catch {
            snapshotStatusMessage = "导出失败：\(error.localizedDescription)"
        }
    }

    func importSnapshot() {
        do {
            try store.importSnapshot()
            if store.space(id: selectedSpaceID) == nil {
                selectedSpaceID = store.rootID
            }
            snapshotStatusMessage = "已从本地备份恢复"
        } catch {
            snapshotStatusMessage = "恢复失败：\(error.localizedDescription)"
        }
    }

}
