import Foundation

public enum ShortcutEmissionPhase: Equatable, Sendable {
    case tap
    case keyDown
    case keyUp
}

public protocol ShortcutEmitting {
    func emit(_ shortcut: Shortcut, phase: ShortcutEmissionPhase) throws
}

public enum MappingDisposition: Equatable, Sendable {
    case released
    case repeated
    case unmapped
    case disabled
    case layerActivated
    case layerReleased
    case coalesced
    case suppressedByTestMode
    case emitted
    case failed(String)
}

public struct MappingResult: Equatable, Sendable {
    public let event: ControllerEvent
    public let layer: MappingLayer
    public let action: MappingAction?
    public let disposition: MappingDisposition

    public init(
        event: ControllerEvent,
        layer: MappingLayer,
        action: MappingAction?,
        disposition: MappingDisposition
    ) {
        self.event = event
        self.layer = layer
        self.action = action
        self.disposition = disposition
    }

    public var shortcut: Shortcut? { action?.shortcut }

    public var functionDescription: String? {
        shortcut.flatMap(CodexShortcutCatalog.description)
    }
}

public struct MappingEngine: Sendable {
    private struct ResolvedPress: Sendable {
        let layer: MappingLayer
        let action: MappingAction
    }

    private var pressedInputs = Set<ControllerInput>()
    private var functionInputs = Set<ControllerInput>()
    private var resolvedPresses: [ControllerInput: ResolvedPress] = [:]
    private var holdOwners: [Shortcut: Set<ControllerInput>] = [:]

    public init() {}

    public var isFunctionLayerActive: Bool {
        !functionInputs.isEmpty
    }

    public mutating func process(
        _ event: ControllerEvent,
        profile: MappingProfile,
        testMode: Bool,
        emitter: any ShortcutEmitting
    ) -> MappingResult {
        switch event.phase {
        case .pressed:
            processPress(event, profile: profile, testMode: testMode, emitter: emitter)
        case .released:
            processRelease(event, emitter: emitter)
        }
    }

    public mutating func releaseAll(emitter: any ShortcutEmitting) throws {
        var firstError: Error?
        for shortcut in holdOwners.keys {
            do {
                try emitter.emit(shortcut, phase: .keyUp)
            } catch {
                if firstError == nil {
                    firstError = error
                }
            }
        }
        resetPressedState()
        if let firstError {
            throw firstError
        }
    }

    public mutating func resetPressedState() {
        pressedInputs.removeAll()
        functionInputs.removeAll()
        resolvedPresses.removeAll()
        holdOwners.removeAll()
    }

    private mutating func processPress(
        _ event: ControllerEvent,
        profile: MappingProfile,
        testMode: Bool,
        emitter: any ShortcutEmitting
    ) -> MappingResult {
        guard pressedInputs.insert(event.input).inserted else {
            return result(event, layer: currentLayer, action: nil, disposition: .repeated)
        }
        guard let mapping = profile.mapping(for: event.input) else {
            return result(event, layer: currentLayer, action: nil, disposition: .unmapped)
        }

        if mapping.primaryAction?.kind == .functionLayer {
            let action = mapping.primaryAction!
            functionInputs.insert(event.input)
            resolvedPresses[event.input] = ResolvedPress(layer: .primary, action: action)
            return result(event, layer: .primary, action: action, disposition: .layerActivated)
        }

        let layer = currentLayer
        guard let action = mapping.action(for: layer) else {
            return result(event, layer: layer, action: nil, disposition: .disabled)
        }
        if action.kind == .functionLayer {
            functionInputs.insert(event.input)
            resolvedPresses[event.input] = ResolvedPress(layer: layer, action: action)
            return result(event, layer: layer, action: action, disposition: .layerActivated)
        }
        resolvedPresses[event.input] = ResolvedPress(layer: layer, action: action)

        guard !testMode else {
            return result(
                event,
                layer: layer,
                action: action,
                disposition: .suppressedByTestMode
            )
        }
        guard let shortcut = action.shortcut else {
            return result(event, layer: layer, action: action, disposition: .disabled)
        }

        do {
            switch action.kind {
            case .tap:
                try emitter.emit(shortcut, phase: .tap)
                return result(event, layer: layer, action: action, disposition: .emitted)
            case .hold:
                var owners = holdOwners[shortcut, default: []]
                let isFirstOwner = owners.isEmpty
                if isFirstOwner {
                    try emitter.emit(shortcut, phase: .keyDown)
                }
                owners.insert(event.input)
                holdOwners[shortcut] = owners
                return result(
                    event,
                    layer: layer,
                    action: action,
                    disposition: isFirstOwner ? .emitted : .coalesced
                )
            case .functionLayer:
                return result(event, layer: layer, action: action, disposition: .layerActivated)
            }
        } catch {
            return result(
                event,
                layer: layer,
                action: action,
                disposition: .failed(error.localizedDescription)
            )
        }
    }

    private mutating func processRelease(
        _ event: ControllerEvent,
        emitter: any ShortcutEmitting
    ) -> MappingResult {
        pressedInputs.remove(event.input)
        guard let resolved = resolvedPresses.removeValue(forKey: event.input) else {
            return result(event, layer: currentLayer, action: nil, disposition: .released)
        }

        if resolved.action.kind == .functionLayer {
            functionInputs.remove(event.input)
            return result(
                event,
                layer: resolved.layer,
                action: resolved.action,
                disposition: .layerReleased
            )
        }
        guard
            resolved.action.kind == .hold,
            let shortcut = resolved.action.shortcut,
            var owners = holdOwners[shortcut],
            owners.remove(event.input) != nil
        else {
            return result(
                event,
                layer: resolved.layer,
                action: resolved.action,
                disposition: .released
            )
        }

        if !owners.isEmpty {
            holdOwners[shortcut] = owners
            return result(
                event,
                layer: resolved.layer,
                action: resolved.action,
                disposition: .coalesced
            )
        }
        holdOwners.removeValue(forKey: shortcut)
        do {
            try emitter.emit(shortcut, phase: .keyUp)
            return result(
                event,
                layer: resolved.layer,
                action: resolved.action,
                disposition: .emitted
            )
        } catch {
            return result(
                event,
                layer: resolved.layer,
                action: resolved.action,
                disposition: .failed(error.localizedDescription)
            )
        }
    }

    private var currentLayer: MappingLayer {
        functionInputs.isEmpty ? .primary : .function
    }

    private func result(
        _ event: ControllerEvent,
        layer: MappingLayer,
        action: MappingAction?,
        disposition: MappingDisposition
    ) -> MappingResult {
        MappingResult(event: event, layer: layer, action: action, disposition: disposition)
    }
}
