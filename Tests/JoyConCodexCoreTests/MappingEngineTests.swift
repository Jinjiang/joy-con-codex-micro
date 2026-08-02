import Foundation
import Testing
@testable import JoyConCodexCore

@Suite("Mapping engine")
struct MappingEngineTests {
    @Test("Tap input emits only on its first press edge")
    func edgeDetection() {
        var engine = MappingEngine()
        let emitter = RecordingEmitter()
        let pressed = ControllerEvent(input: .buttonA, phase: .pressed)
        let released = ControllerEvent(input: .buttonA, phase: .released)

        let first = process(&engine, pressed, emitter: emitter)
        let repeated = process(&engine, pressed, emitter: emitter)
        _ = process(&engine, released, emitter: emitter)
        let second = process(&engine, pressed, emitter: emitter)

        #expect(first.disposition == .emitted)
        #expect(repeated.disposition == .repeated)
        #expect(second.disposition == .emitted)
        #expect(emitter.emissions.map(\.phase) == [.tap, .tap])
    }

    @Test("Function layer resolves the Fn slot without emitting its own key")
    func functionLayerResolution() {
        var engine = MappingEngine()
        let emitter = RecordingEmitter()

        let layer = process(
            &engine,
            ControllerEvent(input: .leftTrigger, phase: .pressed),
            emitter: emitter
        )
        let modified = process(
            &engine,
            ControllerEvent(input: .buttonA, phase: .pressed),
            emitter: emitter
        )

        #expect(layer.disposition == .layerActivated)
        #expect(modified.layer == .function)
        #expect(modified.functionDescription == "Toggle side panel")
        #expect(emitter.emissions.count == 1)
        #expect(emitter.emissions[0].shortcut.formatted == "⌘⌥B")
    }

    @Test("SL uses chat navigation by default and history navigation on Fn")
    func sideButtonLayerResolution() {
        var engine = MappingEngine()
        let emitter = RecordingEmitter()

        let primary = process(&engine, event(.buttonSL, .pressed), emitter: emitter)
        _ = process(&engine, event(.buttonSL, .released), emitter: emitter)
        _ = process(&engine, event(.leftTrigger, .pressed), emitter: emitter)
        let modified = process(&engine, event(.buttonSL, .pressed), emitter: emitter)

        #expect(primary.functionDescription == "Previous chat")
        #expect(primary.shortcut?.formatted == "⌘⇧[")
        #expect(modified.functionDescription == "Back")
        #expect(modified.shortcut?.formatted == "⌘[")
    }

    @Test("Overlapping function keys keep Fn active until both release")
    func overlappingFunctionKeys() {
        var engine = MappingEngine()
        let emitter = RecordingEmitter()

        _ = process(&engine, event(.leftTrigger, .pressed), emitter: emitter)
        _ = process(&engine, event(.rightTrigger, .pressed), emitter: emitter)
        _ = process(&engine, event(.leftTrigger, .released), emitter: emitter)
        #expect(engine.isFunctionLayerActive)
        let modified = process(&engine, event(.buttonX, .pressed), emitter: emitter)
        _ = process(&engine, event(.buttonX, .released), emitter: emitter)
        _ = process(&engine, event(.rightTrigger, .released), emitter: emitter)
        #expect(!engine.isFunctionLayerActive)
        let primary = process(&engine, event(.buttonX, .pressed), emitter: emitter)

        #expect(modified.shortcut?.formatted == "⌘⇧P")
        #expect(primary.shortcut?.formatted == "⌘N")
    }

    @Test("Pressing Fn after a target does not retroactively change its action")
    func pressEdgeLayerSelection() {
        var engine = MappingEngine()
        let emitter = RecordingEmitter()

        let primary = process(&engine, event(.buttonA, .pressed), emitter: emitter)
        _ = process(&engine, event(.leftTrigger, .pressed), emitter: emitter)
        let targetRelease = process(&engine, event(.buttonA, .released), emitter: emitter)

        #expect(primary.layer == .primary)
        #expect(primary.shortcut?.formatted == "Return")
        #expect(targetRelease.layer == .primary)
        #expect(emitter.emissions.count == 1)
    }

    @Test("Overlapping voice controls share one key-down and final key-up")
    func overlappingHoldOwnership() {
        var engine = MappingEngine()
        let emitter = RecordingEmitter()

        let first = process(&engine, event(.leftShoulder, .pressed), emitter: emitter)
        let second = process(&engine, event(.rightShoulder, .pressed), emitter: emitter)
        let firstRelease = process(&engine, event(.leftShoulder, .released), emitter: emitter)
        let finalRelease = process(&engine, event(.rightShoulder, .released), emitter: emitter)

        #expect(first.disposition == .emitted)
        #expect(second.disposition == .coalesced)
        #expect(firstRelease.disposition == .coalesced)
        #expect(finalRelease.disposition == .emitted)
        #expect(emitter.emissions.map(\.phase) == [.keyDown, .keyUp])
        #expect(emitter.emissions.allSatisfy { $0.shortcut.formatted == "⌃⇧D" })
    }

    @Test("Release all posts one key-up for an active held shortcut")
    func releaseAllCleanup() throws {
        var engine = MappingEngine()
        let emitter = RecordingEmitter()
        _ = process(&engine, event(.leftShoulder, .pressed), emitter: emitter)
        _ = process(&engine, event(.rightShoulder, .pressed), emitter: emitter)

        try engine.releaseAll(emitter: emitter)

        #expect(emitter.emissions.map(\.phase) == [.keyDown, .keyUp])
        #expect(!engine.isFunctionLayerActive)
    }

    @Test("Test mode resolves tap and hold actions without any output")
    func testModeSuppression() {
        var engine = MappingEngine()
        let emitter = RecordingEmitter()

        let tap = engine.process(
            event(.buttonA, .pressed),
            profile: .starter,
            testMode: true,
            emitter: emitter
        )
        let hold = engine.process(
            event(.leftShoulder, .pressed),
            profile: .starter,
            testMode: true,
            emitter: emitter
        )
        let release = engine.process(
            event(.leftShoulder, .released),
            profile: .starter,
            testMode: true,
            emitter: emitter
        )

        #expect(tap.disposition == .suppressedByTestMode)
        #expect(hold.disposition == .suppressedByTestMode)
        #expect(release.disposition == .released)
        #expect(emitter.emissions.isEmpty)
    }

    @Test("Disabled selected slot never reaches emitter")
    func disabledMapping() {
        var engine = MappingEngine()
        let emitter = RecordingEmitter()

        let result = process(&engine, event(.buttonPlus, .pressed), emitter: emitter)

        #expect(result.disposition == .disabled)
        #expect(emitter.emissions.isEmpty)
    }

    @Test("Emitter failure is surfaced without a partial success")
    func emitterFailure() {
        var engine = MappingEngine()

        let result = engine.process(
            event(.buttonA, .pressed),
            profile: .starter,
            testMode: false,
            emitter: FailingEmitter()
        )

        guard case let .failed(message) = result.disposition else {
            Issue.record("Expected a failed disposition")
            return
        }
        #expect(message.contains("Synthetic failure"))
    }

    private func process(
        _ engine: inout MappingEngine,
        _ event: ControllerEvent,
        emitter: any ShortcutEmitting
    ) -> MappingResult {
        engine.process(event, profile: .starter, testMode: false, emitter: emitter)
    }

    private func event(_ input: ControllerInput, _ phase: InputPhase) -> ControllerEvent {
        ControllerEvent(input: input, phase: phase)
    }
}

private struct RecordedEmission: Equatable {
    let shortcut: Shortcut
    let phase: ShortcutEmissionPhase
}

private final class RecordingEmitter: ShortcutEmitting {
    var emissions: [RecordedEmission] = []

    func emit(_ shortcut: Shortcut, phase: ShortcutEmissionPhase) {
        emissions.append(RecordedEmission(shortcut: shortcut, phase: phase))
    }
}

private struct FailingEmitter: ShortcutEmitting {
    struct SyntheticFailure: LocalizedError {
        var errorDescription: String? { "Synthetic failure" }
    }

    func emit(_ shortcut: Shortcut, phase: ShortcutEmissionPhase) throws {
        throw SyntheticFailure()
    }
}
