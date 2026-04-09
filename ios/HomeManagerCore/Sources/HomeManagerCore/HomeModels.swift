import Foundation

public struct SpaceNode: Identifiable, Codable, Hashable, Sendable {
    public let id: UUID
    public var name: String
    public var parentID: UUID?
    public var icon: String
    public var note: String

    public init(
        id: UUID = UUID(),
        name: String,
        parentID: UUID? = nil,
        icon: String = "square.grid.2x2",
        note: String = ""
    ) {
        self.id = id
        self.name = name
        self.parentID = parentID
        self.icon = icon
        self.note = note
    }
}

public struct ItemNode: Identifiable, Codable, Hashable, Sendable {
    public let id: UUID
    public var name: String
    public var spaceID: UUID
    public var quantity: Int
    public var tags: [String]

    public init(
        id: UUID = UUID(),
        name: String,
        spaceID: UUID,
        quantity: Int = 1,
        tags: [String] = []
    ) {
        self.id = id
        self.name = name
        self.spaceID = spaceID
        self.quantity = max(1, quantity)
        self.tags = tags
    }
}
