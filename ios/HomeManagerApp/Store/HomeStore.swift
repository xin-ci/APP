import Foundation
import Combine

@MainActor
final class HomeStore: ObservableObject {
    @Published private(set) var spaces: [UUID: SpaceNode]
    @Published private(set) var items: [UUID: ItemNode]

    let rootID: UUID

    init() {
        let root = SpaceNode(name: "我的家", icon: "house.fill", colorHex: "#4F46E5")
        rootID = root.id

        let bedroom = SpaceNode(name: "主卧", parentID: root.id, icon: "bed.double.fill")
        let closet = SpaceNode(name: "衣柜", parentID: bedroom.id, icon: "cabinet.fill")
        let drawer = SpaceNode(name: "上层抽屉", parentID: closet.id, icon: "shippingbox.fill")

        let passport = ItemNode(name: "护照", spaceID: drawer.id, quantity: 2, tags: ["证件"])
        let charger = ItemNode(name: "充电线", spaceID: drawer.id, quantity: 3, tags: ["电子"])

        spaces = [
            root.id: root,
            bedroom.id: bedroom,
            closet.id: closet,
            drawer.id: drawer
        ]
        items = [
            passport.id: passport,
            charger.id: charger
        ]
    }

    func space(id: UUID) -> SpaceNode? {
        spaces[id]
    }

    func childrenSpaces(of parentID: UUID?) -> [SpaceNode] {
        spaces.values
            .filter { $0.parentID == parentID }
            .sorted { $0.name < $1.name }
    }

    func items(in spaceID: UUID) -> [ItemNode] {
        items.values
            .filter { $0.spaceID == spaceID }
            .sorted { $0.name < $1.name }
    }

    func addSpace(name: String, parentID: UUID) {
        var newSpace = SpaceNode(name: name, parentID: parentID, icon: "square.grid.2x2")
        newSpace.updatedAt = .now
        spaces[newSpace.id] = newSpace
    }

    func renameSpace(_ id: UUID, newName: String) {
        guard var space = spaces[id] else { return }
        space.name = newName
        space.updatedAt = .now
        spaces[id] = space
    }

    func addItem(name: String, spaceID: UUID, quantity: Int = 1) {
        var newItem = ItemNode(name: name, spaceID: spaceID, quantity: quantity)
        newItem.updatedAt = .now
        items[newItem.id] = newItem
    }

    func updateItemQuantity(_ id: UUID, quantity: Int) {
        guard var item = items[id] else { return }
        item.quantity = max(1, quantity)
        item.updatedAt = .now
        items[id] = item
    }

    func deleteItem(_ id: UUID) {
        items.removeValue(forKey: id)
    }

    func breadcrumb(for spaceID: UUID) -> [SpaceNode] {
        var trail: [SpaceNode] = []
        var currentID: UUID? = spaceID

        while let id = currentID, let node = spaces[id] {
            trail.append(node)
            currentID = node.parentID
        }

        return trail.reversed()
    }

    func moveItem(_ itemID: UUID, to targetSpaceID: UUID) {
        guard var item = items[itemID], spaces[targetSpaceID] != nil else { return }
        item.spaceID = targetSpaceID
        item.updatedAt = .now
        items[itemID] = item
    }

    func canMoveSpace(_ spaceID: UUID, to targetParentID: UUID?) -> Bool {
        guard spaceID != rootID else { return false }
        guard spaceID != targetParentID else { return false }

        var current = targetParentID
        while let parent = current {
            if parent == spaceID {
                return false
            }
            current = spaces[parent]?.parentID
        }
        return true
    }

    func moveSpace(_ spaceID: UUID, to targetParentID: UUID?) {
        guard canMoveSpace(spaceID, to: targetParentID) else { return }
        guard var space = spaces[spaceID] else { return }
        space.parentID = targetParentID
        space.updatedAt = .now
        spaces[spaceID] = space
    }

    func deleteSpace(_ id: UUID) {
        guard id != rootID else { return }
        let descendants = collectDescendantSpaceIDs(startingAt: id)
        let allToDelete = Set(descendants + [id])

        spaces = spaces.filter { !allToDelete.contains($0.key) }
        items = items.filter { !allToDelete.contains($0.value.spaceID) }
    }

    func search(keyword: String, under rootSpaceID: UUID? = nil) -> ([SpaceNode], [ItemNode]) {
        let query = keyword.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !query.isEmpty else { return ([], []) }

        let targetSpaceIDs: Set<UUID>
        if let rootSpaceID {
            let descendants = collectDescendantSpaceIDs(startingAt: rootSpaceID)
            targetSpaceIDs = Set(descendants + [rootSpaceID])
        } else {
            targetSpaceIDs = Set(spaces.keys)
        }

        let spaceResult = spaces.values
            .filter { targetSpaceIDs.contains($0.id) }
            .filter { $0.name.localizedCaseInsensitiveContains(query) }
            .sorted { $0.name < $1.name }

        let itemResult = items.values
            .filter { targetSpaceIDs.contains($0.spaceID) }
            .filter {
                $0.name.localizedCaseInsensitiveContains(query)
                    || $0.tags.joined(separator: " ").localizedCaseInsensitiveContains(query)
            }
            .sorted { $0.name < $1.name }

        return (spaceResult, itemResult)
    }

    private func collectDescendantSpaceIDs(startingAt id: UUID) -> [UUID] {
        var result: [UUID] = []
        var queue: [UUID] = [id]

        while !queue.isEmpty {
            let current = queue.removeFirst()
            let children = spaces.values
                .filter { $0.parentID == current }
                .map(\.id)
            result.append(contentsOf: children)
            queue.append(contentsOf: children)
        }

        return result
    }
}
