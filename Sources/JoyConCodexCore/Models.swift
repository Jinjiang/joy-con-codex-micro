import Foundation

public enum ControllerInput: String, CaseIterable, Codable, Sendable, Hashable, Identifiable {
    case buttonA
    case buttonB
    case buttonX
    case buttonY
    case buttonPlus
    case buttonMinus
    case buttonHome
    case buttonCapture
    case buttonSL
    case buttonSR
    case dpadUp
    case dpadDown
    case dpadLeft
    case dpadRight
    case leftShoulder
    case rightShoulder
    case leftTrigger
    case rightTrigger
    case leftStickPress
    case rightStickPress
    case leftStickUp
    case leftStickDown
    case leftStickLeft
    case leftStickRight
    case rightStickUp
    case rightStickDown
    case rightStickLeft
    case rightStickRight

    public var id: String { rawValue }

    public var displayName: String {
        switch self {
        case .buttonA: "A"
        case .buttonB: "B"
        case .buttonX: "X"
        case .buttonY: "Y"
        case .buttonPlus: "Plus"
        case .buttonMinus: "Minus"
        case .buttonHome: "Home"
        case .buttonCapture: "Capture"
        case .buttonSL: "SL"
        case .buttonSR: "SR"
        case .dpadUp: "D-pad Up"
        case .dpadDown: "D-pad Down"
        case .dpadLeft: "D-pad Left"
        case .dpadRight: "D-pad Right"
        case .leftShoulder: "Left Shoulder"
        case .rightShoulder: "Right Shoulder"
        case .leftTrigger: "Left Trigger"
        case .rightTrigger: "Right Trigger"
        case .leftStickPress: "Left Stick Press"
        case .rightStickPress: "Right Stick Press"
        case .leftStickUp: "Left Stick Up"
        case .leftStickDown: "Left Stick Down"
        case .leftStickLeft: "Left Stick Left"
        case .leftStickRight: "Left Stick Right"
        case .rightStickUp: "Right Stick Up"
        case .rightStickDown: "Right Stick Down"
        case .rightStickLeft: "Right Stick Left"
        case .rightStickRight: "Right Stick Right"
        }
    }
}

public enum InputPhase: String, Codable, Sendable {
    case pressed
    case released
}

public struct ControllerEvent: Codable, Equatable, Sendable {
    public let input: ControllerInput
    public let phase: InputPhase
    public let timestamp: Date

    public init(input: ControllerInput, phase: InputPhase, timestamp: Date = .now) {
        self.input = input
        self.phase = phase
        self.timestamp = timestamp
    }
}

public enum KeyModifier: String, CaseIterable, Codable, Sendable, Hashable, Identifiable {
    case command
    case option
    case control
    case shift

    public var id: String { rawValue }

    public var symbol: String {
        switch self {
        case .command: "⌘"
        case .option: "⌥"
        case .control: "⌃"
        case .shift: "⇧"
        }
    }
}

public struct KeyOption: Identifiable, Equatable, Sendable {
    public let keyCode: UInt16
    public let label: String

    public var id: UInt16 { keyCode }

    public init(keyCode: UInt16, label: String) {
        self.keyCode = keyCode
        self.label = label
    }
}

public enum KeyCatalog {
    public static let options: [KeyOption] = [
        .init(keyCode: 0, label: "A"),
        .init(keyCode: 11, label: "B"),
        .init(keyCode: 8, label: "C"),
        .init(keyCode: 2, label: "D"),
        .init(keyCode: 14, label: "E"),
        .init(keyCode: 3, label: "F"),
        .init(keyCode: 5, label: "G"),
        .init(keyCode: 4, label: "H"),
        .init(keyCode: 34, label: "I"),
        .init(keyCode: 38, label: "J"),
        .init(keyCode: 40, label: "K"),
        .init(keyCode: 37, label: "L"),
        .init(keyCode: 46, label: "M"),
        .init(keyCode: 45, label: "N"),
        .init(keyCode: 31, label: "O"),
        .init(keyCode: 35, label: "P"),
        .init(keyCode: 12, label: "Q"),
        .init(keyCode: 15, label: "R"),
        .init(keyCode: 1, label: "S"),
        .init(keyCode: 17, label: "T"),
        .init(keyCode: 32, label: "U"),
        .init(keyCode: 9, label: "V"),
        .init(keyCode: 13, label: "W"),
        .init(keyCode: 7, label: "X"),
        .init(keyCode: 16, label: "Y"),
        .init(keyCode: 6, label: "Z"),
        .init(keyCode: 18, label: "1"),
        .init(keyCode: 19, label: "2"),
        .init(keyCode: 20, label: "3"),
        .init(keyCode: 21, label: "4"),
        .init(keyCode: 23, label: "5"),
        .init(keyCode: 22, label: "6"),
        .init(keyCode: 26, label: "7"),
        .init(keyCode: 28, label: "8"),
        .init(keyCode: 25, label: "9"),
        .init(keyCode: 29, label: "0"),
        .init(keyCode: 33, label: "["),
        .init(keyCode: 30, label: "]"),
        .init(keyCode: 49, label: "Space"),
        .init(keyCode: 36, label: "Return"),
        .init(keyCode: 48, label: "Tab"),
        .init(keyCode: 51, label: "Delete"),
        .init(keyCode: 53, label: "Escape"),
        .init(keyCode: 123, label: "Left Arrow"),
        .init(keyCode: 124, label: "Right Arrow"),
        .init(keyCode: 125, label: "Down Arrow"),
        .init(keyCode: 126, label: "Up Arrow"),
    ]

    public static func option(for keyCode: UInt16) -> KeyOption? {
        options.first { $0.keyCode == keyCode }
    }
}

public struct Shortcut: Codable, Equatable, Hashable, Sendable {
    public var keyCode: UInt16
    public var displayLabel: String
    public var modifiers: Set<KeyModifier>

    public init(
        keyCode: UInt16,
        displayLabel: String,
        modifiers: Set<KeyModifier> = []
    ) {
        self.keyCode = keyCode
        self.displayLabel = displayLabel
        self.modifiers = modifiers
    }

    public var formatted: String {
        let prefix = KeyModifier.allCases
            .filter(modifiers.contains)
            .map(\.symbol)
            .joined()
        return prefix + displayLabel
    }
}

public enum MappingActionKind: String, CaseIterable, Codable, Sendable, Identifiable {
    case tap
    case hold
    case functionLayer

    public var id: String { rawValue }

    public var displayName: String {
        switch self {
        case .tap: "Tap"
        case .hold: "Hold"
        case .functionLayer: "Function layer"
        }
    }
}

public struct MappingAction: Codable, Equatable, Sendable {
    public var kind: MappingActionKind
    public var shortcut: Shortcut?

    public init(kind: MappingActionKind, shortcut: Shortcut? = nil) {
        self.kind = kind
        self.shortcut = shortcut
    }

    public static func tap(_ shortcut: Shortcut) -> MappingAction {
        MappingAction(kind: .tap, shortcut: shortcut)
    }

    public static func hold(_ shortcut: Shortcut) -> MappingAction {
        MappingAction(kind: .hold, shortcut: shortcut)
    }

    public static var functionLayer: MappingAction {
        MappingAction(kind: .functionLayer)
    }

    public var formatted: String {
        switch kind {
        case .tap:
            shortcut?.formatted ?? "Invalid tap"
        case .hold:
            shortcut.map { "Hold \($0.formatted)" } ?? "Invalid hold"
        case .functionLayer:
            "Function layer"
        }
    }
}

public enum MappingLayer: String, Codable, Sendable {
    case primary = "Default"
    case function = "Fn"
}

public struct InputMapping: Codable, Equatable, Sendable, Identifiable {
    public var input: ControllerInput
    public var primaryAction: MappingAction?
    public var functionAction: MappingAction?

    public var id: ControllerInput { input }

    public init(
        input: ControllerInput,
        primaryAction: MappingAction?,
        functionAction: MappingAction? = nil
    ) {
        self.input = input
        self.primaryAction = primaryAction
        self.functionAction = functionAction
    }

    public func action(for layer: MappingLayer) -> MappingAction? {
        switch layer {
        case .primary: primaryAction
        case .function: functionAction
        }
    }
}

public struct MappingProfile: Codable, Equatable, Sendable {
    public static let currentSchemaVersion = 2

    public var schemaVersion: Int
    public var name: String
    public var mappings: [InputMapping]

    public init(
        schemaVersion: Int = Self.currentSchemaVersion,
        name: String,
        mappings: [InputMapping]
    ) {
        self.schemaVersion = schemaVersion
        self.name = name
        self.mappings = mappings
    }

    public func mapping(for input: ControllerInput) -> InputMapping? {
        mappings.first { $0.input == input }
    }

    public mutating func update(_ mapping: InputMapping) {
        if let index = mappings.firstIndex(where: { $0.input == mapping.input }) {
            mappings[index] = mapping
        } else {
            mappings.append(mapping)
        }
    }
}

public enum ProfileValidationError: LocalizedError, Equatable, Sendable {
    case unsupportedSchema(Int)
    case emptyName
    case duplicateInput(ControllerInput)
    case unsupportedKeyCode(input: ControllerInput, keyCode: UInt16)
    case emptyKeyLabel(ControllerInput)
    case mismatchedKeyLabel(input: ControllerInput, expected: String, actual: String)
    case missingShortcut(input: ControllerInput, layer: MappingLayer)
    case unexpectedFunctionLayerShortcut(input: ControllerInput, layer: MappingLayer)

    public var errorDescription: String? {
        switch self {
        case let .unsupportedSchema(version):
            "Profile schema \(version) is unsupported."
        case .emptyName:
            "The profile name cannot be empty."
        case let .duplicateInput(input):
            "The profile contains more than one mapping for \(input.displayName)."
        case let .unsupportedKeyCode(input, keyCode):
            "\(input.displayName) uses unsupported key code \(keyCode)."
        case let .emptyKeyLabel(input):
            "\(input.displayName) has an empty key label."
        case let .mismatchedKeyLabel(input, expected, actual):
            "\(input.displayName) labels key code as \(actual), but \(expected) is required."
        case let .missingShortcut(input, layer):
            "\(input.displayName) has a \(layer.rawValue) action without a shortcut."
        case let .unexpectedFunctionLayerShortcut(input, layer):
            "\(input.displayName) has an unexpected shortcut on its \(layer.rawValue) function-layer action."
        }
    }
}

public extension MappingProfile {
    func validate() throws {
        guard schemaVersion == Self.currentSchemaVersion else {
            throw ProfileValidationError.unsupportedSchema(schemaVersion)
        }
        guard !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw ProfileValidationError.emptyName
        }

        var seen = Set<ControllerInput>()
        for mapping in mappings {
            guard seen.insert(mapping.input).inserted else {
                throw ProfileValidationError.duplicateInput(mapping.input)
            }
            try validate(mapping.primaryAction, for: mapping.input, layer: .primary)
            try validate(mapping.functionAction, for: mapping.input, layer: .function)
        }
    }

    private func validate(
        _ action: MappingAction?,
        for input: ControllerInput,
        layer: MappingLayer
    ) throws {
        guard let action else { return }
        if action.kind == .functionLayer {
            guard action.shortcut == nil else {
                throw ProfileValidationError.unexpectedFunctionLayerShortcut(
                    input: input,
                    layer: layer
                )
            }
            return
        }
        guard let shortcut = action.shortcut else {
            throw ProfileValidationError.missingShortcut(input: input, layer: layer)
        }
        guard let key = KeyCatalog.option(for: shortcut.keyCode) else {
            throw ProfileValidationError.unsupportedKeyCode(
                input: input,
                keyCode: shortcut.keyCode
            )
        }
        guard !shortcut.displayLabel.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw ProfileValidationError.emptyKeyLabel(input)
        }
        guard shortcut.displayLabel == key.label else {
            throw ProfileValidationError.mismatchedKeyLabel(
                input: input,
                expected: key.label,
                actual: shortcut.displayLabel
            )
        }
    }

    static var starter: MappingProfile {
        let enter = MappingAction.tap(Shortcut(keyCode: 36, displayLabel: "Return"))
        let escape = MappingAction.tap(Shortcut(keyCode: 53, displayLabel: "Escape"))
        let delete = MappingAction.tap(Shortcut(keyCode: 51, displayLabel: "Delete"))
        let newChat = MappingAction.tap(
            Shortcut(keyCode: 45, displayLabel: "N", modifiers: [.command])
        )
        let newSideChat = MappingAction.tap(
            Shortcut(keyCode: 1, displayLabel: "S", modifiers: [.command, .option])
        )
        let closeChat = MappingAction.tap(
            Shortcut(keyCode: 13, displayLabel: "W", modifiers: [.command])
        )
        let back = MappingAction.tap(
            Shortcut(keyCode: 33, displayLabel: "[", modifiers: [.command])
        )
        let forward = MappingAction.tap(
            Shortcut(keyCode: 30, displayLabel: "]", modifiers: [.command])
        )
        let previousChat = MappingAction.tap(
            Shortcut(keyCode: 33, displayLabel: "[", modifiers: [.command, .shift])
        )
        let nextChat = MappingAction.tap(
            Shortcut(keyCode: 30, displayLabel: "]", modifiers: [.command, .shift])
        )
        let toggleSidePanel = MappingAction.tap(
            Shortcut(keyCode: 11, displayLabel: "B", modifiers: [.command, .option])
        )
        let toggleBottomPanel = MappingAction.tap(
            Shortcut(keyCode: 38, displayLabel: "J", modifiers: [.command])
        )
        let toggleSidebar = MappingAction.tap(
            Shortcut(keyCode: 11, displayLabel: "B", modifiers: [.command])
        )
        let dictate = MappingAction.hold(
            Shortcut(keyCode: 2, displayLabel: "D", modifiers: [.control, .shift])
        )
        let arrowActions: [ControllerInput: MappingAction] = [
            .leftStickUp: .tap(Shortcut(keyCode: 126, displayLabel: "Up Arrow")),
            .leftStickDown: .tap(Shortcut(keyCode: 125, displayLabel: "Down Arrow")),
            .leftStickLeft: .tap(Shortcut(keyCode: 123, displayLabel: "Left Arrow")),
            .leftStickRight: .tap(Shortcut(keyCode: 124, displayLabel: "Right Arrow")),
            .rightStickUp: .tap(Shortcut(keyCode: 126, displayLabel: "Up Arrow")),
            .rightStickDown: .tap(Shortcut(keyCode: 125, displayLabel: "Down Arrow")),
            .rightStickLeft: .tap(Shortcut(keyCode: 123, displayLabel: "Left Arrow")),
            .rightStickRight: .tap(Shortcut(keyCode: 124, displayLabel: "Right Arrow")),
        ]

        let primary: [ControllerInput: MappingAction] = [
            .buttonA: enter,
            .buttonB: escape,
            .buttonX: newSideChat,
            .buttonY: delete,
            .buttonPlus: newChat,
            .buttonMinus: newChat,
            .buttonSL: previousChat,
            .buttonSR: nextChat,
            .dpadRight: enter,
            .dpadDown: escape,
            .dpadUp: newSideChat,
            .dpadLeft: delete,
            .leftShoulder: dictate,
            .rightShoulder: dictate,
            .leftTrigger: .functionLayer,
            .rightTrigger: .functionLayer,
        ].merging(arrowActions) { current, _ in current }

        let function: [ControllerInput: MappingAction] = [
            .buttonA: toggleSidePanel,
            .buttonB: toggleBottomPanel,
            .buttonX: closeChat,
            .buttonY: toggleSidebar,
            .buttonSL: back,
            .buttonSR: forward,
            .dpadRight: toggleSidePanel,
            .dpadDown: toggleBottomPanel,
            .dpadUp: closeChat,
            .dpadLeft: toggleSidebar,
            .leftShoulder: dictate,
            .rightShoulder: dictate,
        ].merging(arrowActions) { current, _ in current }

        return MappingProfile(
            name: "Codex Keyboard Layers",
            mappings: ControllerInput.allCases.map { input in
                InputMapping(
                    input: input,
                    primaryAction: primary[input],
                    functionAction: function[input]
                )
            }
        )
    }

    func addingMissingStarterMappings() -> MappingProfile {
        var completed = self
        for mapping in MappingProfile.starter.mappings
        where completed.mapping(for: mapping.input) == nil {
            completed.mappings.append(mapping)
        }
        return completed
    }
}

public enum CodexShortcutCatalog {
    public static func description(for shortcut: Shortcut) -> String? {
        descriptions[shortcut]
    }

    private static let descriptions: [Shortcut: String] = [
        Shortcut(keyCode: 36, displayLabel: "Return"): "Enter / confirm",
        Shortcut(keyCode: 53, displayLabel: "Escape"): "Cancel or dismiss",
        Shortcut(keyCode: 45, displayLabel: "N", modifiers: [.command]): "New chat",
        Shortcut(keyCode: 1, displayLabel: "S", modifiers: [.command, .option]):
            "New side chat",
        Shortcut(keyCode: 13, displayLabel: "W", modifiers: [.command]): "Close chat",
        Shortcut(keyCode: 33, displayLabel: "[", modifiers: [.command]): "Back",
        Shortcut(keyCode: 30, displayLabel: "]", modifiers: [.command]): "Forward",
        Shortcut(keyCode: 33, displayLabel: "[", modifiers: [.command, .shift]):
            "Previous chat",
        Shortcut(keyCode: 30, displayLabel: "]", modifiers: [.command, .shift]):
            "Next chat",
        Shortcut(keyCode: 11, displayLabel: "B", modifiers: [.command, .option]):
            "Toggle side panel",
        Shortcut(keyCode: 38, displayLabel: "J", modifiers: [.command]):
            "Toggle bottom panel",
        Shortcut(keyCode: 35, displayLabel: "P", modifiers: [.command, .shift]):
            "Command menu",
        Shortcut(keyCode: 11, displayLabel: "B", modifiers: [.command]):
            "Toggle sidebar",
        Shortcut(keyCode: 2, displayLabel: "D", modifiers: [.control, .shift]):
            "Voice dictation",
    ]
}
