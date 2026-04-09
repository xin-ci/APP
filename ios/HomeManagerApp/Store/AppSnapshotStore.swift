import Foundation

struct AppSnapshot: Codable {
    let spaces: [SpaceNode]
    let items: [ItemNode]
    let rootID: UUID
}

enum AppSnapshotStore {
    static var defaultFileURL: URL {
        let directory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
            ?? FileManager.default.temporaryDirectory
        return directory.appendingPathComponent("home_manager_snapshot.json")
    }

    static func save(snapshot: AppSnapshot, to fileURL: URL = defaultFileURL) throws {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        encoder.dateEncodingStrategy = .iso8601
        let data = try encoder.encode(snapshot)

        let parent = fileURL.deletingLastPathComponent()
        try FileManager.default.createDirectory(at: parent, withIntermediateDirectories: true)
        try data.write(to: fileURL, options: .atomic)
    }

    static func load(from fileURL: URL = defaultFileURL) throws -> AppSnapshot {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let data = try Data(contentsOf: fileURL)
        return try decoder.decode(AppSnapshot.self, from: data)
    }
}
