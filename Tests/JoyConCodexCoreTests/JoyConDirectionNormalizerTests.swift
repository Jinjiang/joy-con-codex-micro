import Testing
@testable import JoyConCodexCore

@Suite("Joy-Con portrait direction normalization")
struct JoyConDirectionNormalizerTests {
    @Test("Left directions remain physical D-pad inputs")
    func leftDirectionalPad() {
        #expect(input(.up, .leftDirectionalPad) == .dpadUp)
        #expect(input(.down, .leftDirectionalPad) == .dpadDown)
        #expect(input(.left, .leftDirectionalPad) == .dpadLeft)
        #expect(input(.right, .leftDirectionalPad) == .dpadRight)
    }

    @Test("Right micro directions become right-stick inputs")
    func rightStick() {
        #expect(input(.up, .rightStick) == .rightStickUp)
        #expect(input(.down, .rightStick) == .rightStickDown)
        #expect(input(.left, .rightStick) == .rightStickLeft)
        #expect(input(.right, .rightStick) == .rightStickRight)
    }

    @Test("Stick filter uses hysteresis and emits one edge per transition")
    func hysteresis() {
        var filter = StickDirectionFilter()

        #expect(filter.update(x: 0.64, y: 0).isEmpty)
        #expect(filter.update(x: 0.70, y: 0) == [edge(.right, .pressed)])
        #expect(filter.update(x: 0.50, y: 0).isEmpty)
        #expect(filter.update(x: 0.36, y: 0).isEmpty)
        #expect(filter.update(x: 0.34, y: 0) == [edge(.right, .released)])
        #expect(filter.update(x: 0.70, y: 0) == [edge(.right, .pressed)])
    }

    @Test("Opposing direction releases before the new press")
    func opposingDirections() {
        var filter = StickDirectionFilter()
        _ = filter.update(x: 0.8, y: 0)

        #expect(
            filter.update(x: -0.8, y: 0) == [
                edge(.right, .released),
                edge(.left, .pressed),
            ]
        )
    }

    @Test("Reset releases every active diagonal direction")
    func reset() {
        var filter = StickDirectionFilter()
        _ = filter.update(x: 0.8, y: 0.8)

        #expect(
            filter.reset() == [
                edge(.up, .released),
                edge(.right, .released),
            ]
        )
        #expect(filter.reset().isEmpty)
    }

    private func input(
        _ direction: PortraitDirection,
        _ role: SingleJoyConDirectionRole
    ) -> ControllerInput {
        SingleJoyConDirectionNormalizer.input(for: direction, role: role)
    }

    private func edge(
        _ direction: PortraitDirection,
        _ phase: InputPhase
    ) -> StickDirectionEdge {
        StickDirectionEdge(direction: direction, phase: phase)
    }
}
