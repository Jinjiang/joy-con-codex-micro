import Testing
@testable import JoyConCodexCore

@Suite("Right Joy-Con HID mapping")
struct RightJoyConHIDMappingTests {
    @Test("Recorded button usages map to their physical labels")
    func recordedButtonUsages() {
        let expected: [UInt32: ControllerInput] = [
            1: .buttonA,
            2: .buttonX,
            3: .buttonB,
            4: .buttonY,
            5: .buttonSL,
            6: .buttonSR,
            10: .buttonPlus,
            12: .rightStickPress,
            13: .buttonHome,
            15: .rightShoulder,
            16: .rightTrigger,
        ]

        for (usage, input) in expected {
            #expect(RightJoyConHIDMapping.input(forButtonUsage: usage) == input)
        }
    }

    @Test("Unknown and left Joy-Con-only usages are ignored")
    func unknownUsages() {
        for usage: UInt32 in [0, 7, 8, 9, 11, 14, 17] {
            #expect(RightJoyConHIDMapping.input(forButtonUsage: usage) == nil)
        }
    }
}
