import Foundation

public struct HomeTreeEngine: Sendable {
    public private(set) var spaces: [UUID: SpaceNode]
    public private(set) var items: [UUID: ItemNode]
    public let rootID: UUID

    public init(rootName: String = "我的家") {
        let root = SpaceNode(name: rootName, parentID: nil, icon: "house.fill")
        self.rootID = root.id
        self.spaces = [root.id: root]
        self.items = [:]
    }

    public mutating func addSpace(name: String, parentID: UUID) -> UUID? {
        guard spaces[parentID] != nil else { return nil }
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }

        let node = SpaceNode(name: trimmed, parentID: parentID)
        spaces[node.id] = node
        return node.id
    }

    public mutating func addItem(name: String, spaceID: UUID, quantity: Int = 1, tags: [String] = []) -> UUID? {
        guard spaces[spaceID] != nil else { return nil }
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }

        let item = ItemNode(name: trimmed, spaceID: spaceID, quantity: quantity, tags: tags)
        items[item.id] = item
        return item.id
    }

    public func breadcrumb(for spaceID: UUID) -> [SpaceNode] {
        var result: [SpaceNode] = []
        var current: UUID? = spaceID

        while let id = current, let node = spaces[id] {
            result.append(node)
            current = node.parentID
        }

        return result.reversed()
    }

    public func children(of parentID: UUID?) -> [SpaceNode] {
        spaces.values
            .filter { $0.parentID == parentID }
            .sorted(by: { $0.name < $1.name })
    }

    public func items(in spaceID: UUID) -> [ItemNode] {
        items.values
            .filter { $0.spaceID == spaceID }
            .sorted(by: { $0.name < $1.name })
    }

    public func canMoveSpace(_ spaceID: UUID, to targetParentID: UUID?) -> Bool {
        guard spaceID != rootID else { return false }
        guard spaceID != targetParentID else { return false }

        var current = targetParentID
        while let id = current {
            if id == spaceID {
                return false
            }
            current = spaces[id]?.parentID
        }

        return true
    }

    public mutating func moveSpace(_ spaceID: UUID, to targetParentID: UUID?) -> Bool {
        guard canMoveSpace(spaceID, to: targetParentID) else { return false }
        guard var space = spaces[spaceID] else { return false }
        guard targetParentID == nil || spaces[targetParentID!] != nil else { return false }

        space.parentID = targetParentID
        spaces[spaceID] = space
        return true
    }

    public mutating func deleteSpace(_ id: UUID) -> Bool {
        guard id != rootID, spaces[id] != nil else { return false }

        let descendants = descendantSpaceIDs(startingAt: id)
        let all = Set(descendants + [id])

        spaces = spaces.filter { !all.contains($0.key) }
        items = items.filter { !all.contains($0.value.spaceID) }
        return true
    }

    public mutating func updateItemQuantity(_ itemID: UUID, quantity: Int) -> Bool {
        guard var item = items[itemID] else { return false }
        item.quantity = max(1, quantity)
        items[itemID] = item
        return true
    }

    public func search(keyword: String, in rootSpaceID: UUID? = nil) -> ([SpaceNode], [ItemNode]) {
        let query = keyword.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !query.isEmpty else { return ([], []) }

        let scope: Set<UUID>
        if let rootSpaceID {
            guard spaces[rootSpaceID] != nil else { return ([], []) }
            scope = Set(descendantSpaceIDs(startingAt: rootSpaceID) + [rootSpaceID])
        } else {
            scope = Set(spaces.keys)
        }

        let foundSpaces = spaces.values
            .filter { scope.contains($0.id) }
            .filter { $0.name.localizedCaseInsensitiveContains(query) }
            .sorted(by: { $0.name < $1.name })

        let foundItems = items.values
            .filter { scope.contains($0.spaceID) }
            .filter {
                $0.name.localizedCaseInsensitiveContains(query)
                    || $0.tags.joined(separator: " ").localizedCaseInsensitiveContains(query)
            }
            .sorted(by: { $0.name < $1.name })

        return (foundSpaces, foundItems)
    }

    private func descendantSpaceIDs(startingAt id: UUID) -> [UUID] {
        var queue: [UUID] = [id]
        var result: [UUID] = []

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
