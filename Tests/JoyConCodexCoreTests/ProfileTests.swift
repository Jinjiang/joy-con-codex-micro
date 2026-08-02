import Foundation
import Testing
@testable import JoyConCodexCore

@Suite("Mapping profile")
struct ProfileTests {
    @Test("Starter profile contains the complete layered keyboard layout")
    func starterProfileIsCompleteAndValid() throws {
        let profile = MappingProfile.starter

        try profile.validate()
        #expect(profile.schemaVersion == 2)
        #expect(profile.name == "Codex Keyboard Layers")
        #expect(profile.mappings.count == ControllerInput.allCases.count)
        #expect(Set(profile.mappings.map(\.input)) == Set(ControllerInput.allCases))

        #expect(shortcut(profile, .buttonA, .primary)?.formatted == "Return")
        #expect(shortcut(profile, .buttonA, .function)?.formatted == "⌘⌥B")
        #expect(shortcut(profile, .buttonB, .primary)?.formatted == "Escape")
        #expect(shortcut(profile, .buttonB, .function)?.formatted == "⌘J")
        #expect(shortcut(profile, .buttonX, .primary)?.formatted == "⌘⌥S")
        #expect(shortcut(profile, .buttonX, .function)?.formatted == "⌘W")
        #expect(shortcut(profile, .buttonY, .primary)?.formatted == "Delete")
        #expect(shortcut(profile, .buttonY, .function)?.formatted == "⌘B")
        #expect(shortcut(profile, .buttonPlus, .primary)?.formatted == "⌘N")
        #expect(shortcut(profile, .buttonMinus, .primary)?.formatted == "⌘N")

        #expect(shortcut(profile, .dpadRight, .primary)?.formatted == "Return")
        #expect(shortcut(profile, .dpadDown, .primary)?.formatted == "Escape")
        #expect(shortcut(profile, .dpadUp, .primary)?.formatted == "⌘⌥S")
        #expect(shortcut(profile, .dpadUp, .function)?.formatted == "⌘W")
        #expect(shortcut(profile, .dpadLeft, .primary)?.formatted == "Delete")

        #expect(shortcut(profile, .buttonSL, .primary)?.formatted == "⌘⇧[")
        #expect(shortcut(profile, .buttonSL, .function)?.formatted == "⌘[")
        #expect(shortcut(profile, .buttonSR, .primary)?.formatted == "⌘⇧]")
        #expect(shortcut(profile, .buttonSR, .function)?.formatted == "⌘]")

        let voice = profile.mapping(for: .leftShoulder)?.primaryAction
        #expect(voice?.kind == .hold)
        #expect(voice?.shortcut?.formatted == "⌃⇧D")
        #expect(profile.mapping(for: .rightShoulder)?.primaryAction == voice)
        #expect(profile.mapping(for: .leftTrigger)?.primaryAction?.kind == .functionLayer)
        #expect(profile.mapping(for: .rightTrigger)?.primaryAction?.kind == .functionLayer)

        #expect(shortcut(profile, .rightStickUp, .primary)?.formatted == "Up Arrow")
        #expect(shortcut(profile, .leftStickLeft, .function)?.formatted == "Left Arrow")
        #expect(profile.mapping(for: .buttonHome)?.functionAction == nil)
        #expect(profile.mapping(for: .rightStickPress)?.primaryAction == nil)
    }

    @Test("Known shortcut descriptions require an exact chord")
    func codexDescriptions() {
        #expect(
            CodexShortcutCatalog.description(
                for: Shortcut(keyCode: 45, displayLabel: "N", modifiers: [.command])
            ) == "New chat"
        )
        #expect(
            CodexShortcutCatalog.description(
                for: Shortcut(
                    keyCode: 1,
                    displayLabel: "S",
                    modifiers: [.command, .option]
                )
            ) == "New side chat"
        )
        #expect(
            CodexShortcutCatalog.description(
                for: Shortcut(keyCode: 13, displayLabel: "W", modifiers: [.command])
            ) == "Close chat"
        )
        #expect(
            CodexShortcutCatalog.description(
                for: Shortcut(keyCode: 45, displayLabel: "N", modifiers: [.option])
            ) == nil
        )
    }

    @Test("Validation rejects duplicate inputs")
    func validationRejectsDuplicateInputs() {
        let mapping = InputMapping(
            input: .buttonA,
            primaryAction: .tap(Shortcut(keyCode: 0, displayLabel: "A"))
        )
        let profile = MappingProfile(name: "Duplicate", mappings: [mapping, mapping])

        #expect(throws: ProfileValidationError.duplicateInput(.buttonA)) {
            try profile.validate()
        }
    }

    @Test("Validation rejects unsupported key codes")
    func validationRejectsUnsupportedKeyCodes() {
        let profile = MappingProfile(
            name: "Invalid",
            mappings: [
                InputMapping(
                    input: .buttonA,
                    primaryAction: .tap(
                        Shortcut(keyCode: .max, displayLabel: "Unknown")
                    )
                ),
            ]
        )

        #expect {
            try profile.validate()
        } throws: { error in
            guard case ProfileValidationError.unsupportedKeyCode(.buttonA, .max) = error else {
                return false
            }
            return true
        }
    }

    @Test("Validation rejects a label that disagrees with its key code")
    func validationRejectsMismatchedLabels() {
        let profile = MappingProfile(
            name: "Invalid",
            mappings: [
                InputMapping(
                    input: .buttonA,
                    primaryAction: .tap(Shortcut(keyCode: 0, displayLabel: "B"))
                ),
            ]
        )

        #expect {
            try profile.validate()
        } throws: { error in
            guard case ProfileValidationError.mismatchedKeyLabel(
                input: .buttonA,
                expected: "A",
                actual: "B"
            ) = error else {
                return false
            }
            return true
        }
    }

    @Test("Validation rejects shortcut actions without shortcut data")
    func validationRejectsMissingShortcut() {
        let profile = MappingProfile(
            name: "Invalid",
            mappings: [
                InputMapping(
                    input: .buttonA,
                    primaryAction: MappingAction(kind: .hold)
                ),
            ]
        )

        #expect(
            throws: ProfileValidationError.missingShortcut(
                input: .buttonA,
                layer: .primary
            )
        ) {
            try profile.validate()
        }
    }

    private func shortcut(
        _ profile: MappingProfile,
        _ input: ControllerInput,
        _ layer: MappingLayer
    ) -> Shortcut? {
        profile.mapping(for: input)?.action(for: layer)?.shortcut
    }
}
