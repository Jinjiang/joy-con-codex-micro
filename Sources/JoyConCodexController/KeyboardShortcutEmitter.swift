import ApplicationServices
import CoreGraphics
import Foundation
import JoyConCodexCore

enum ShortcutEmissionError: LocalizedError {
    case accessibilityPermissionRequired
    case invalidShortcut
    case eventCreationFailed

    var errorDescription: String? {
        switch self {
        case .accessibilityPermissionRequired:
            "Accessibility permission is required for live output."
        case .invalidShortcut:
            "The resolved shortcut is invalid."
        case .eventCreationFailed:
            "macOS could not create a keyboard event."
        }
    }
}

enum AccessibilityPermission {
    static func isTrusted(prompt: Bool = false) -> Bool {
        let options = [
            "AXTrustedCheckOptionPrompt": prompt,
        ] as CFDictionary
        return AXIsProcessTrustedWithOptions(options)
    }
}

struct CoreGraphicsShortcutEmitter: ShortcutEmitting {
    func emit(_ shortcut: Shortcut, phase: ShortcutEmissionPhase) throws {
        guard AccessibilityPermission.isTrusted() else {
            throw ShortcutEmissionError.accessibilityPermissionRequired
        }
        guard
            let option = KeyCatalog.option(for: shortcut.keyCode),
            option.label == shortcut.displayLabel
        else {
            throw ShortcutEmissionError.invalidShortcut
        }

        let source = CGEventSource(stateID: .hidSystemState)
        guard
            let keyDown = CGEvent(
                keyboardEventSource: source,
                virtualKey: CGKeyCode(shortcut.keyCode),
                keyDown: true
            ),
            let keyUp = CGEvent(
                keyboardEventSource: source,
                virtualKey: CGKeyCode(shortcut.keyCode),
                keyDown: false
            )
        else {
            throw ShortcutEmissionError.eventCreationFailed
        }

        let flags = shortcut.modifiers.reduce(into: CGEventFlags()) { result, modifier in
            switch modifier {
            case .command:
                result.insert(.maskCommand)
            case .option:
                result.insert(.maskAlternate)
            case .control:
                result.insert(.maskControl)
            case .shift:
                result.insert(.maskShift)
            }
        }

        keyDown.flags = flags
        keyUp.flags = flags
        switch phase {
        case .tap:
            keyDown.post(tap: .cghidEventTap)
            keyUp.post(tap: .cghidEventTap)
        case .keyDown:
            keyDown.post(tap: .cghidEventTap)
        case .keyUp:
            keyUp.post(tap: .cghidEventTap)
        }
    }
}
