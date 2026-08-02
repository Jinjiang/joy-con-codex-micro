public enum CompanionOutputState: Equatable, Sendable {
    case testMode
    case live
    case blockedByAccessibility
}

public struct MenuBarStatus: Equatable, Sendable {
    public let supportedControllerCount: Int
    public let outputState: CompanionOutputState

    public init(
        supportedControllerCount: Int,
        testMode: Bool,
        accessibilityTrusted: Bool
    ) {
        self.supportedControllerCount = max(0, supportedControllerCount)
        if testMode {
            self.outputState = .testMode
        } else if accessibilityTrusted {
            self.outputState = .live
        } else {
            self.outputState = .blockedByAccessibility
        }
    }

    public var isControllerConnected: Bool {
        supportedControllerCount > 0
    }

    public var controllerSummary: String {
        switch supportedControllerCount {
        case 0:
            "No Joy-Con connected"
        case 1:
            "1 Joy-Con connected"
        default:
            "\(supportedControllerCount) Joy-Cons connected"
        }
    }

    public var outputSummary: String {
        switch outputState {
        case .testMode:
            "Test mode — shortcuts blocked"
        case .live:
            "Live output"
        case .blockedByAccessibility:
            "Live output blocked — Accessibility required"
        }
    }

    public var systemImage: String {
        switch outputState {
        case .blockedByAccessibility:
            "exclamationmark.triangle.fill"
        case .testMode, .live:
            isControllerConnected ? "gamecontroller.fill" : "gamecontroller"
        }
    }
}
