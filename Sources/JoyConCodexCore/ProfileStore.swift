import Foundation

public enum ProfileLoadResult: Equatable, Sendable {
    case loaded(MappingProfile)
    case defaults(MappingProfile)
    case recovered(MappingProfile, message: String)

    public var profile: MappingProfile {
        switch self {
        case let .loaded(profile), let .defaults(profile), let .recovered(profile, _):
            profile
        }
    }

    public var recoveryMessage: String? {
        if case let .recovered(_, message) = self {
            message
        } else {
            nil
        }
    }
}

public struct ProfileStore: Sendable {
    public let profileURL: URL

    public init(profileURL: URL) {
        self.profileURL = profileURL
    }

    public static func applicationSupport(
        fileManager: FileManager = .default
    ) throws -> ProfileStore {
        let applicationSupport = try fileManager.url(
            for: .applicationSupportDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        )
        return ProfileStore(
            profileURL: applicationSupport
                .appendingPathComponent("JoyConCodexController", isDirectory: true)
                .appendingPathComponent("mapping-profile.json", isDirectory: false)
        )
    }

    public func load(fileManager: FileManager = .default) -> ProfileLoadResult {
        guard fileManager.fileExists(atPath: profileURL.path) else {
            return .defaults(.starter)
        }

        do {
            let data = try Data(contentsOf: profileURL)
            let profile = try decode(data)
            return .loaded(profile)
        } catch {
            return .recovered(
                .starter,
                message: "Stored profile was left untouched: \(error.localizedDescription)"
            )
        }
    }

    public func save(
        _ profile: MappingProfile,
        fileManager: FileManager = .default
    ) throws {
        try profile.validate()
        let directory = profileURL.deletingLastPathComponent()
        try fileManager.createDirectory(
            at: directory,
            withIntermediateDirectories: true
        )
        let data = try Self.encoder.encode(profile)
        try data.write(to: profileURL, options: [.atomic])
    }

    @discardableResult
    public func reset(fileManager: FileManager = .default) throws -> MappingProfile {
        let profile = MappingProfile.starter
        try save(profile, fileManager: fileManager)
        return profile
    }

    public func importProfile(from sourceURL: URL) throws -> MappingProfile {
        let data = try Data(contentsOf: sourceURL)
        return try decode(data)
    }

    public func export(
        _ profile: MappingProfile,
        to destinationURL: URL
    ) throws {
        try profile.validate()
        let data = try Self.encoder.encode(profile)
        try data.write(to: destinationURL, options: [.atomic])
    }

    public func decode(_ data: Data) throws -> MappingProfile {
        let version = try Self.decoder.decode(ProfileVersionEnvelope.self, from: data)
        let decoded: MappingProfile
        switch version.schemaVersion {
        case 1:
            decoded = try Self.decoder.decode(LegacyMappingProfile.self, from: data).migrated()
        case MappingProfile.currentSchemaVersion:
            decoded = try Self.decoder.decode(MappingProfile.self, from: data)
        default:
            throw ProfileValidationError.unsupportedSchema(version.schemaVersion)
        }
        let profile = decoded.addingMissingStarterMappings()
        try profile.validate()
        return profile
    }

    private static var encoder: JSONEncoder {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys, .withoutEscapingSlashes]
        return encoder
    }

    private static var decoder: JSONDecoder {
        JSONDecoder()
    }
}

private struct ProfileVersionEnvelope: Decodable {
    let schemaVersion: Int
}

private struct LegacyMappingProfile: Decodable {
    let schemaVersion: Int
    let name: String
    let mappings: [LegacyInputMapping]

    func migrated() -> MappingProfile {
        MappingProfile(
            name: name,
            mappings: mappings.map { mapping in
                InputMapping(
                    input: mapping.input,
                    primaryAction: mapping.isEnabled ? .tap(mapping.shortcut) : nil
                )
            }
        )
    }
}

private struct LegacyInputMapping: Decodable {
    let input: ControllerInput
    let shortcut: Shortcut
    let isEnabled: Bool
}
