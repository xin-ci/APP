import Foundation

public struct HomeSnapshot: Codable, Sendable, Equatable {
    public var rootID: UUID
    public var spaces: [SpaceNode]
    public var items: [ItemNode]

    public init(rootID: UUID, spaces: [SpaceNode], items: [ItemNode]) {
        self.rootID = rootID
        self.spaces = spaces
        self.items = items
    }
}

public enum HomeSnapshotCoder {
    public static func encode(_ snapshot: HomeSnapshot) throws -> Data {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        return try encoder.encode(snapshot)
    }

    public static func decode(_ data: Data) throws -> HomeSnapshot {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try decoder.decode(HomeSnapshot.self, from: data)
    }
}

public enum HomeSnapshotFileStore {
    public static func save(_ snapshot: HomeSnapshot, to fileURL: URL) throws {
        let data = try HomeSnapshotCoder.encode(snapshot)
        let directory = fileURL.deletingLastPathComponent()
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        try data.write(to: fileURL, options: .atomic)
    }

    public static func load(from fileURL: URL) throws -> HomeSnapshot {
        let data = try Data(contentsOf: fileURL)
        return try HomeSnapshotCoder.decode(data)
    }
}
