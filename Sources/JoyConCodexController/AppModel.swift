import AppKit
import Combine
import Foundation
import JoyConCodexCore

@MainActor
final class AppModel: ObservableObject {
    @Published private(set) var controllers: [ControllerDescriptor] = []
    @Published private(set) var recentEvent: ControllerEvent?
    @Published private(set) var recentResult: MappingResult?
    @Published private(set) var statusMessage = "Starting controller discovery…"
    @Published private(set) var feedbackMessage = "Visual feedback is ready."
    @Published private(set) var accessibilityTrusted = false
    @Published var profile: MappingProfile
    @Published var testMode: Bool {
        didSet {
            userDefaults.set(testMode, forKey: Self.testModeKey)
            if testMode {
                releaseKeyboardState(reason: "Test mode enabled")
            } else {
                mappingEngine.resetPressedState()
            }
        }
    }

    private static let testModeKey = "JoyConCodexController.testMode"

    private let adapter: GameControllerAdapter
    private let emitter: CoreGraphicsShortcutEmitter
    private let profileStore: ProfileStore?
    private let userDefaults: UserDefaults
    private var mappingEngine = MappingEngine()

    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
        self.adapter = GameControllerAdapter()
        self.emitter = CoreGraphicsShortcutEmitter()

        do {
            let store = try ProfileStore.applicationSupport()
            self.profileStore = store
            let loadResult = store.load()
            self.profile = loadResult.profile
            if let recovery = loadResult.recoveryMessage {
                self.statusMessage = recovery
            }
        } catch {
            self.profileStore = nil
            self.profile = .starter
            self.statusMessage = "Using defaults in memory: \(error.localizedDescription)"
        }

        if userDefaults.object(forKey: Self.testModeKey) == nil {
            self.testMode = true
        } else {
            self.testMode = userDefaults.bool(forKey: Self.testModeKey)
        }

        self.accessibilityTrusted = AccessibilityPermission.isTrusted()
        adapter.onControllersChanged = { [weak self] descriptors in
            self?.handleControllers(descriptors)
        }
        adapter.onEvent = { [weak self] event in
            self?.handle(event)
        }
        adapter.onInputSourceStatus = { [weak self] status in
            self?.feedbackMessage = status
        }
        if let inputSourceStatus = adapter.inputSourceStatus {
            feedbackMessage = inputSourceStatus
        }
        _ = NotificationCenter.default.addObserver(
            forName: NSApplication.willTerminateNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            Task { @MainActor [weak self] in
                self?.releaseKeyboardState(reason: "Application terminating")
            }
        }
        adapter.rescan()
    }

    var supportedControllers: [ControllerDescriptor] {
        controllers.filter(\.isSupported)
    }

    var unsupportedControllers: [ControllerDescriptor] {
        controllers.filter { !$0.isSupported }
    }

    var menuBarStatus: MenuBarStatus {
        MenuBarStatus(
            supportedControllerCount: supportedControllers.count,
            testMode: testMode,
            accessibilityTrusted: accessibilityTrusted
        )
    }

    func rescan() {
        statusMessage = "Scanning for controllers exposed by macOS…"
        adapter.rescan()
    }

    func requestAccessibilityPermission() {
        accessibilityTrusted = AccessibilityPermission.isTrusted(prompt: true)
        statusMessage = accessibilityTrusted
            ? "Accessibility permission is available."
            : "Enable this app in System Settings → Privacy & Security → Accessibility."
    }

    func refreshAccessibilityPermission() {
        accessibilityTrusted = AccessibilityPermission.isTrusted()
    }

    func update(_ mapping: InputMapping) {
        var candidate = profile
        candidate.update(mapping)
        do {
            try candidate.validate()
            releaseKeyboardState(reason: "Mapping changed")
            profile = candidate
            try saveProfile()
            statusMessage = "Saved \(mapping.input.displayName)."
        } catch {
            statusMessage = "Mapping was not saved: \(error.localizedDescription)"
        }
    }

    func resetProfile() {
        do {
            releaseKeyboardState(reason: "Profile reset")
            if let profileStore {
                profile = try profileStore.reset()
            } else {
                profile = .starter
            }
            statusMessage = "Starter mappings restored."
        } catch {
            statusMessage = "Could not reset profile: \(error.localizedDescription)"
        }
    }

    func importProfile() {
        let panel = NSOpenPanel()
        panel.allowedContentTypes = [.json]
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false
        panel.message = "Choose a Joy-Con Codex Controller profile."
        guard panel.runModal() == .OK, let url = panel.url else { return }

        do {
            guard let profileStore else {
                throw CocoaError(.fileNoSuchFile)
            }
            let imported = try profileStore.importProfile(from: url)
            try profileStore.save(imported)
            releaseKeyboardState(reason: "Profile imported")
            profile = imported
            statusMessage = "Imported \(imported.name)."
        } catch {
            statusMessage = "Import rejected: \(error.localizedDescription)"
        }
    }

    func exportProfile() {
        let panel = NSSavePanel()
        panel.allowedContentTypes = [.json]
        panel.nameFieldStringValue = "joy-con-codex-profile.json"
        panel.message = "Export the validated mapping profile."
        guard panel.runModal() == .OK, let url = panel.url else { return }

        do {
            guard let profileStore else {
                throw CocoaError(.fileNoSuchFile)
            }
            try profileStore.export(profile, to: url)
            statusMessage = "Exported \(profile.name)."
        } catch {
            statusMessage = "Export failed: \(error.localizedDescription)"
        }
    }

    private func saveProfile() throws {
        guard let profileStore else {
            throw CocoaError(.fileNoSuchFile)
        }
        try profileStore.save(profile)
    }

    private func handleControllers(_ descriptors: [ControllerDescriptor]) {
        let previousActiveID = supportedControllers.first?.id
        let hadSupportedController = !supportedControllers.isEmpty
        controllers = descriptors
        let hasSupportedController = !supportedControllers.isEmpty
        let currentActiveID = supportedControllers.first?.id

        if hasSupportedController {
            if let previousActiveID, previousActiveID != currentActiveID {
                releaseKeyboardState(reason: "Active Joy-Con changed")
            }
            let names = supportedControllers.map(\.name).joined(separator: ", ")
            statusMessage = "Connected: \(names)"
            if !hadSupportedController {
                feedbackMessage = "Joy-Con connected. Visual feedback is active."
            }
        } else {
            releaseKeyboardState(reason: "Joy-Con disconnected")
            statusMessage = descriptors.isEmpty
                ? "No controllers detected. Pair a Joy-Con in macOS Bluetooth settings."
                : "No supported Joy-Con detected."
        }
    }

    private func handle(_ event: ControllerEvent) {
        recentEvent = event
        let result = mappingEngine.process(
            event,
            profile: profile,
            testMode: testMode,
            emitter: emitter
        )
        recentResult = result
        accessibilityTrusted = AccessibilityPermission.isTrusted()

        let actionDescription = result.functionDescription
            ?? result.action?.formatted
            ?? "Disabled"
        switch result.disposition {
        case .emitted, .coalesced, .suppressedByTestMode, .layerActivated, .layerReleased:
            let layer = result.layer.rawValue
            feedbackMessage = "\(event.input.displayName) [\(layer)] → \(actionDescription)."
            if event.phase == .pressed, result.disposition != .layerActivated {
                feedbackMessage += " " + adapter.playConfirmation()
            }
        case .failed(let message):
            feedbackMessage = "\(event.input.displayName) blocked: \(message)"
        case .released, .repeated, .unmapped, .disabled:
            break
        }
    }

    private func releaseKeyboardState(reason: String) {
        do {
            try mappingEngine.releaseAll(emitter: emitter)
        } catch {
            feedbackMessage = "\(reason); held shortcut cleanup failed: \(error.localizedDescription)"
        }
    }
}
