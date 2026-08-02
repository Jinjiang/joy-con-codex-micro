import Foundation
import IOKit.hid
import JoyConCodexCore

enum RightJoyConHIDError: LocalizedError {
    case openFailed(IOReturn)
    case mainRunLoopUnavailable

    var errorDescription: String? {
        switch self {
        case let .openFailed(result):
            let code = String(format: "0x%08X", UInt32(bitPattern: result))
            return "Could not open the right Joy-Con HID input (\(code))."
        case .mainRunLoopUnavailable:
            return "The main run loop is unavailable for right Joy-Con input."
        }
    }
}

final class RightJoyConHIDAdapter {
    var onEvent: ((ControllerEvent) -> Void)?
    var onStatus: ((String) -> Void)?

    private var manager: IOHIDManager?
    private var scheduledRunLoop: CFRunLoop?

    var isRunning: Bool { manager != nil }

    func start() throws {
        guard manager == nil else { return }

        let manager = IOHIDManagerCreate(
            kCFAllocatorDefault,
            IOOptionBits(kIOHIDOptionsTypeNone)
        )
        let matching: [String: Any] = [
            kIOHIDVendorIDKey: RightJoyConHIDMapping.vendorID,
            kIOHIDProductIDKey: RightJoyConHIDMapping.productID,
        ]
        let context = Unmanaged.passUnretained(self).toOpaque()
        guard let runLoop = CFRunLoopGetMain() else {
            throw RightJoyConHIDError.mainRunLoopUnavailable
        }

        IOHIDManagerSetDeviceMatching(manager, matching as CFDictionary)
        IOHIDManagerRegisterDeviceMatchingCallback(
            manager,
            rightJoyConMatchedCallback,
            context
        )
        IOHIDManagerRegisterDeviceRemovalCallback(
            manager,
            rightJoyConRemovedCallback,
            context
        )
        IOHIDManagerRegisterInputValueCallback(
            manager,
            rightJoyConInputCallback,
            context
        )
        IOHIDManagerScheduleWithRunLoop(
            manager,
            runLoop,
            CFRunLoopMode.defaultMode.rawValue
        )

        let result = IOHIDManagerOpen(
            manager,
            IOOptionBits(kIOHIDOptionsTypeNone)
        )
        guard result == kIOReturnSuccess else {
            IOHIDManagerUnscheduleFromRunLoop(
                manager,
                runLoop,
                CFRunLoopMode.defaultMode.rawValue
            )
            throw RightJoyConHIDError.openFailed(result)
        }

        self.manager = manager
        scheduledRunLoop = runLoop
    }

    func stop() {
        guard let manager else { return }
        if let scheduledRunLoop {
            IOHIDManagerUnscheduleFromRunLoop(
                manager,
                scheduledRunLoop,
                CFRunLoopMode.defaultMode.rawValue
            )
        }
        IOHIDManagerClose(manager, IOOptionBits(kIOHIDOptionsTypeNone))
        self.manager = nil
        scheduledRunLoop = nil
    }

    func handleMatchedDevice() {
        onStatus?("Right Joy-Con raw button input is active.")
    }

    func handleRemovedDevice() {
        onStatus?("Right Joy-Con raw button input disconnected.")
    }

    func handle(_ value: IOHIDValue) {
        let element = IOHIDValueGetElement(value)
        let usagePage = IOHIDElementGetUsagePage(element)
        let usage = IOHIDElementGetUsage(element)

        guard
            usagePage == RightJoyConHIDMapping.buttonUsagePage,
            let input = RightJoyConHIDMapping.input(forButtonUsage: usage)
        else {
            return
        }

        onEvent?(
            ControllerEvent(
                input: input,
                phase: IOHIDValueGetIntegerValue(value) == 0 ? .released : .pressed
            )
        )
    }
}

private func rightJoyConAdapter(
    from context: UnsafeMutableRawPointer?
) -> RightJoyConHIDAdapter? {
    guard let context else { return nil }
    return Unmanaged<RightJoyConHIDAdapter>
        .fromOpaque(context)
        .takeUnretainedValue()
}

private func rightJoyConMatchedCallback(
    context: UnsafeMutableRawPointer?,
    result: IOReturn,
    sender: UnsafeMutableRawPointer?,
    device: IOHIDDevice
) {
    guard result == kIOReturnSuccess else { return }
    rightJoyConAdapter(from: context)?.handleMatchedDevice()
}

private func rightJoyConRemovedCallback(
    context: UnsafeMutableRawPointer?,
    result: IOReturn,
    sender: UnsafeMutableRawPointer?,
    device: IOHIDDevice
) {
    guard result == kIOReturnSuccess else { return }
    rightJoyConAdapter(from: context)?.handleRemovedDevice()
}

private func rightJoyConInputCallback(
    context: UnsafeMutableRawPointer?,
    result: IOReturn,
    sender: UnsafeMutableRawPointer?,
    value: IOHIDValue
) {
    guard result == kIOReturnSuccess else { return }
    rightJoyConAdapter(from: context)?.handle(value)
}
