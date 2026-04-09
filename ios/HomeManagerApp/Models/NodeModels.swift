import Foundation

enum NodeKind: String, Codable {
    case space
    case item
}

struct SpaceNode: Identifiable, Codable, Hashable {
    let id: UUID
    var name: String
    var parentID: UUID?
    var icon: String
    var colorHex: String
    var note: String
    var createdAt: Date
    var updatedAt: Date

    init(
        id: UUID = UUID(),
        name: String,
        parentID: UUID? = nil,
        icon: String = "house",
        colorHex: String = "#4F46E5",
        note: String = "",
        createdAt: Date = .now,
        updatedAt: Date = .now
    ) {
        self.id = id
        self.name = name
        self.parentID = parentID
        self.icon = icon
        self.colorHex = colorHex
        self.note = note
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

struct ItemNode: Identifiable, Codable, Hashable {
    let id: UUID
    var name: String
    var spaceID: UUID
    var quantity: Int
    var tags: [String]
    var note: String
    var createdAt: Date
    var updatedAt: Date

    init(
        id: UUID = UUID(),
        name: String,
        spaceID: UUID,
        quantity: Int = 1,
        tags: [String] = [],
        note: String = "",
        createdAt: Date = .now,
        updatedAt: Date = .now
    ) {
        self.id = id
        self.name = name
        self.spaceID = spaceID
        self.quantity = quantity
        self.tags = tags
        self.note = note
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}
