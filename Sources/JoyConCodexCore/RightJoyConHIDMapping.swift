public enum RightJoyConHIDMapping {
    public static let vendorID = 0x057E
    public static let productID = 0x2007
    public static let buttonUsagePage: UInt32 = 0x09

    public static func input(forButtonUsage usage: UInt32) -> ControllerInput? {
        switch usage {
        case 1: .buttonA
        case 2: .buttonX
        case 3: .buttonB
        case 4: .buttonY
        case 5: .buttonSL
        case 6: .buttonSR
        case 10: .buttonPlus
        case 12: .rightStickPress
        case 13: .buttonHome
        case 15: .rightShoulder
        case 16: .rightTrigger
        default: nil
        }
    }
}
