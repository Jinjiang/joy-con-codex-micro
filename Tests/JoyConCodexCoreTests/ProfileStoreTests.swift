import Foundation
import Testing
@testable import JoyConCodexCore

@Suite("Profile persistence")
struct ProfileStoreTests {
    @Test("Profile saves and loads as versioned JSON")
    func profileRoundTrip() throws {
        let fixture = try TemporaryProfileFixture()
        let profile = MappingProfile.starter

        try fixture.store.save(profile)
        let result = fixture.store.load()

        #expect(result == .loaded(profile))
        let data = try Data(contentsOf: fixture.store.profileURL)
        let json = try #require(
            JSONSerialization.jsonObject(with: data) as? [String: Any]
        )
        #expect(json["schemaVersion"] as? Int == MappingProfile.currentSchemaVersion)
    }

    @Test("Unreadable profile remains untouched while defaults recover")
    func corruptProfileRecovery() throws {
        let fixture = try TemporaryProfileFixture()
        let corrupt = Data("{ definitely-not-json".utf8)
        try corrupt.write(to: fixture.store.profileURL)

        let result = fixture.store.load()

        #expect(result.profile == .starter)
        #expect(result.recoveryMessage != nil)
        #expect(try Data(contentsOf: fixture.store.profileURL) == corrupt)
    }

    @Test("Reset persists starter defaults")
    func resetPersistsDefaults() throws {
        let fixture = try TemporaryProfileFixture()
        var modified = MappingProfile.starter
        modified.name = "Modified"
        try fixture.store.save(modified)

        let reset = try fixture.store.reset()

        #expect(reset == .starter)
        #expect(fixture.store.load() == .loaded(.starter))
    }

    @Test("Import validates before replacing active data")
    func importValidation() throws {
        let fixture = try TemporaryProfileFixture()
        let sourceURL = fixture.directory.appendingPathComponent("import.json")
        try Data("{}".utf8).write(to: sourceURL)

        #expect(throws: (any Error).self) {
            try fixture.store.importProfile(from: sourceURL)
        }
    }

    @Test("Export writes a profile accepted by import")
    func exportAndImport() throws {
        let fixture = try TemporaryProfileFixture()
        let exportURL = fixture.directory.appendingPathComponent("export.json")

        try fixture.store.export(.starter, to: exportURL)
        let imported = try fixture.store.importProfile(from: exportURL)

        #expect(imported == .starter)
    }

    @Test("Loading an older profile adds newly supported controller inputs")
    func olderProfileAddsNewInputs() throws {
        let fixture = try TemporaryProfileFixture()
        var olderProfile = MappingProfile.starter
        olderProfile.mappings.removeAll {
            $0.input == .buttonSL || $0.input == .buttonSR
        }
        try fixture.store.save(olderProfile)

        let loaded = fixture.store.load().profile

        #expect(loaded.mapping(for: .buttonSL) != nil)
        #expect(loaded.mapping(for: .buttonSR) != nil)
        #expect(loaded.mappings.count == ControllerInput.allCases.count)
    }

    @Test("Schema v1 profile migrates without gaining Fn actions on existing inputs")
    func schemaV1Migration() throws {
        let fixture = try TemporaryProfileFixture()
        let legacy = Data(
            #"""
            {
              "schemaVersion": 1,
              "name": "My legacy profile",
              "mappings": [
                {
                  "input": "buttonA",
                  "shortcut": {
                    "keyCode": 45,
                    "displayLabel": "N",
                    "modifiers": ["command"]
                  },
                  "isEnabled": true
                },
                {
                  "input": "buttonY",
                  "shortcut": {
                    "keyCode": 53,
                    "displayLabel": "Escape",
                    "modifiers": []
                  },
                  "isEnabled": false
                }
              ]
            }
            """#.utf8
        )
        try legacy.write(to: fixture.store.profileURL)

        let loaded = fixture.store.load().profile

        #expect(loaded.schemaVersion == 2)
        #expect(loaded.name == "My legacy profile")
        #expect(loaded.mapping(for: .buttonA)?.primaryAction?.shortcut?.formatted == "⌘N")
        #expect(loaded.mapping(for: .buttonA)?.functionAction == nil)
        #expect(loaded.mapping(for: .buttonY)?.primaryAction == nil)
        #expect(loaded.mapping(for: .buttonY)?.functionAction == nil)
        #expect(loaded.mapping(for: .buttonSL) != nil)
        #expect(try Data(contentsOf: fixture.store.profileURL) == legacy)
    }
}

private struct TemporaryProfileFixture {
    let directory: URL
    let store: ProfileStore

    init() throws {
        directory = FileManager.default.temporaryDirectory
            .appendingPathComponent(
                "JoyConCodexCoreTests-\(UUID().uuidString)",
                isDirectory: true
            )
        try FileManager.default.createDirectory(
            at: directory,
            withIntermediateDirectories: true
        )
        store = ProfileStore(
            profileURL: directory.appendingPathComponent("mapping-profile.json")
        )
    }
}
