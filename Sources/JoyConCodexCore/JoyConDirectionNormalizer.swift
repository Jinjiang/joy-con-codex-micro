import Foundation

public enum PortraitDirection: String, CaseIterable, Hashable, Sendable {
    case up
    case down
    case left
    case right
}

public enum SingleJoyConDirectionRole: Sendable {
    case leftDirectionalPad
    case rightStick
}

public enum SingleJoyConDirectionNormalizer {
    public static func input(
        for direction: PortraitDirection,
        role: SingleJoyConDirectionRole
    ) -> ControllerInput {
        switch (role, direction) {
        case (.leftDirectionalPad, .up): .dpadUp
        case (.leftDirectionalPad, .down): .dpadDown
        case (.leftDirectionalPad, .left): .dpadLeft
        case (.leftDirectionalPad, .right): .dpadRight
        case (.rightStick, .up): .rightStickUp
        case (.rightStick, .down): .rightStickDown
        case (.rightStick, .left): .rightStickLeft
        case (.rightStick, .right): .rightStickRight
        }
    }
}

public struct StickDirectionEdge: Equatable, Sendable {
    public let direction: PortraitDirection
    public let phase: InputPhase

    public init(direction: PortraitDirection, phase: InputPhase) {
        self.direction = direction
        self.phase = phase
    }
}

public struct StickDirectionFilter: Sendable {
    public let activationThreshold: Float
    public let releaseThreshold: Float
    private var activeDirections = Set<PortraitDirection>()

    public init(activationThreshold: Float = 0.65, releaseThreshold: Float = 0.35) {
        precondition(activationThreshold > releaseThreshold)
        precondition(releaseThreshold >= 0)
        self.activationThreshold = activationThreshold
        self.releaseThreshold = releaseThreshold
    }

    public mutating func update(x: Float, y: Float) -> [StickDirectionEdge] {
        let next = Set(PortraitDirection.allCases.filter { direction in
            isActive(direction, x: x, y: y)
        })
        let releases = PortraitDirection.allCases
            .filter { activeDirections.contains($0) && !next.contains($0) }
            .map { StickDirectionEdge(direction: $0, phase: .released) }
        let presses = PortraitDirection.allCases
            .filter { !activeDirections.contains($0) && next.contains($0) }
            .map { StickDirectionEdge(direction: $0, phase: .pressed) }
        activeDirections = next
        return releases + presses
    }

    public mutating func reset() -> [StickDirectionEdge] {
        let releases = PortraitDirection.allCases
            .filter(activeDirections.contains)
            .map { StickDirectionEdge(direction: $0, phase: .released) }
        activeDirections.removeAll()
        return releases
    }

    private func isActive(_ direction: PortraitDirection, x: Float, y: Float) -> Bool {
        let threshold = activeDirections.contains(direction)
            ? releaseThreshold
            : activationThreshold
        return switch direction {
        case .up: y >= threshold
        case .down: y <= -threshold
        case .left: x <= -threshold
        case .right: x >= threshold
        }
    }
}
