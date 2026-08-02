import CoreHaptics
import Foundation
import GameController
import JoyConCodexCore

enum JoyConSide: String, Sendable {
    case left = "Left Joy-Con"
    case right = "Right Joy-Con"
    case pair = "Joy-Con Pair"
    case unknown = "Joy-Con"
}

struct ControllerDescriptor: Identifiable, Equatable, Sendable {
    let id: String
    let name: String
    let productCategory: String
    let side: JoyConSide
    let profile: String
    let isSupported: Bool
}

@MainActor
final class GameControllerAdapter {
    var onControllersChanged: (([ControllerDescriptor]) -> Void)?
    var onEvent: ((ControllerEvent) -> Void)?
    var onInputSourceStatus: ((String) -> Void)?

    private(set) var descriptors: [ControllerDescriptor] = []
    private var activeController: GCController?
    private var activeControllerID: String?
    private var connectObserver: NSObjectProtocol?
    private var disconnectObserver: NSObjectProtocol?
    private var hapticEngine: CHHapticEngine?
    private let rightJoyConHIDAdapter = RightJoyConHIDAdapter()
    private var usesRightJoyConHIDFallback = false
    private var stickFilters: [String: StickDirectionFilter] = [:]

    private(set) var inputSourceStatus: String?

    init() {
        GCController.shouldMonitorBackgroundEvents = true
        rightJoyConHIDAdapter.onEvent = { [weak self] event in
            Task { @MainActor [weak self] in
                self?.onEvent?(event)
            }
        }
        rightJoyConHIDAdapter.onStatus = { [weak self] status in
            Task { @MainActor [weak self] in
                self?.publishInputSourceStatus(status)
            }
        }
        installNotifications()
        refresh()
    }

    func rescan() {
        GCController.startWirelessControllerDiscovery { [weak self] in
            Task { @MainActor [weak self] in
                self?.refresh()
            }
        }
        refresh()
    }

    func stopDiscovery() {
        GCController.stopWirelessControllerDiscovery()
    }

    @discardableResult
    func playConfirmation() -> String {
        guard let haptics = activeController?.haptics else {
            return "Visual feedback only — this controller exposes no haptics."
        }
        guard haptics.supportedLocalities.contains(.default) else {
            return "Visual feedback only — default haptics are unsupported."
        }
        guard let engine = haptics.createEngine(withLocality: .default) else {
            return "Visual feedback continued; haptic engine creation failed."
        }

        do {
            let event = CHHapticEvent(
                eventType: .hapticTransient,
                parameters: [
                    CHHapticEventParameter(
                        parameterID: .hapticIntensity,
                        value: 0.35
                    ),
                    CHHapticEventParameter(
                        parameterID: .hapticSharpness,
                        value: 0.35
                    ),
                ],
                relativeTime: 0
            )
            let pattern = try CHHapticPattern(events: [event], parameters: [])
            let player = try engine.makePlayer(with: pattern)
            try engine.start()
            try player.start(atTime: 0)
            hapticEngine = engine
            return "Controller confirmation played."
        } catch {
            return "Visual feedback continued; haptics failed: \(error.localizedDescription)"
        }
    }

    private func installNotifications() {
        connectObserver = NotificationCenter.default.addObserver(
            forName: .GCControllerDidConnect,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            Task { @MainActor [weak self] in
                self?.refresh()
            }
        }
        disconnectObserver = NotificationCenter.default.addObserver(
            forName: .GCControllerDidDisconnect,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            Task { @MainActor [weak self] in
                self?.refresh()
            }
        }
    }

    private func refresh() {
        let controllers = GCController.controllers()
        descriptors = controllers.map(descriptor)
        onControllersChanged?(descriptors)

        let supported = controllers.first { isJoyCon($0) }
        let supportedID = supported.map(controllerID)
        configureRightJoyConHIDFallback(for: supported)
        if supportedID != activeControllerID {
            stickFilters.removeAll()
            activeController = supported
            activeControllerID = supportedID
            if let supported, let supportedID {
                attachHandlers(to: supported, controllerID: supportedID)
            }
        }
    }

    private func configureRightJoyConHIDFallback(for controller: GCController?) {
        let requiresFallback = controller.map {
            side(for: $0) == .right
                && $0.extendedGamepad == nil
                && $0.microGamepad != nil
        } ?? false

        if requiresFallback, !rightJoyConHIDAdapter.isRunning {
            do {
                try rightJoyConHIDAdapter.start()
                usesRightJoyConHIDFallback = true
                publishInputSourceStatus("Using complete right Joy-Con raw button input.")
            } catch {
                usesRightJoyConHIDFallback = false
                publishInputSourceStatus(
                    "Right Joy-Con raw input unavailable: \(error.localizedDescription)"
                )
            }
        } else if !requiresFallback, rightJoyConHIDAdapter.isRunning {
            rightJoyConHIDAdapter.stop()
            usesRightJoyConHIDFallback = false
            publishInputSourceStatus("Using Apple GameController input.")
        }
    }

    private func publishInputSourceStatus(_ status: String) {
        inputSourceStatus = status
        onInputSourceStatus?(status)
    }

    private func descriptor(for controller: GCController) -> ControllerDescriptor {
        let supported = isJoyCon(controller)
        return ControllerDescriptor(
            id: controllerID(controller),
            name: controller.vendorName ?? controller.productCategory,
            productCategory: controller.productCategory,
            side: supported ? side(for: controller) : .unknown,
            profile: profileName(for: controller),
            isSupported: supported
        )
    }

    private func controllerID(_ controller: GCController) -> String {
        String(ObjectIdentifier(controller).hashValue)
    }

    private func isJoyCon(_ controller: GCController) -> Bool {
        let identity = [
            controller.vendorName ?? "",
            controller.productCategory,
        ]
        .joined(separator: " ")
        .lowercased()
        return identity.contains("joy-con") || identity.contains("joy con")
    }

    private func side(for controller: GCController) -> JoyConSide {
        let identity = [
            controller.vendorName ?? "",
            controller.productCategory,
        ]
        .joined(separator: " ")
        .lowercased()

        if identity.contains("(l)") || identity.contains("left") {
            return .left
        }
        if identity.contains("(r)") || identity.contains("right") {
            return .right
        }
        if identity.contains("pair") || identity.contains("dual") {
            return .pair
        }
        return .unknown
    }

    private func profileName(for controller: GCController) -> String {
        if controller.extendedGamepad != nil {
            return "Extended gamepad"
        }
        if controller.microGamepad != nil {
            return "Micro gamepad"
        }
        return "Physical input profile"
    }

    private func attachHandlers(to controller: GCController, controllerID: String) {
        if let gamepad = controller.extendedGamepad {
            bind(gamepad.buttonA, to: .buttonA, controllerID: controllerID)
            bind(gamepad.buttonB, to: .buttonB, controllerID: controllerID)
            bind(gamepad.buttonX, to: .buttonX, controllerID: controllerID)
            bind(gamepad.buttonY, to: .buttonY, controllerID: controllerID)
            bind(gamepad.buttonMenu, to: .buttonPlus, controllerID: controllerID)
            bind(gamepad.buttonOptions, to: .buttonMinus, controllerID: controllerID)
            bind(gamepad.buttonHome, to: .buttonHome, controllerID: controllerID)
            bind(gamepad.leftShoulder, to: .leftShoulder, controllerID: controllerID)
            bind(gamepad.rightShoulder, to: .rightShoulder, controllerID: controllerID)
            bind(gamepad.leftTrigger, to: .leftTrigger, controllerID: controllerID)
            bind(gamepad.rightTrigger, to: .rightTrigger, controllerID: controllerID)
            bind(
                gamepad.leftThumbstickButton,
                to: .leftStickPress,
                controllerID: controllerID
            )
            bind(
                gamepad.rightThumbstickButton,
                to: .rightStickPress,
                controllerID: controllerID
            )
            bind(gamepad.dpad.up, to: .dpadUp, controllerID: controllerID)
            bind(gamepad.dpad.down, to: .dpadDown, controllerID: controllerID)
            bind(gamepad.dpad.left, to: .dpadLeft, controllerID: controllerID)
            bind(gamepad.dpad.right, to: .dpadRight, controllerID: controllerID)
            bindStick(
                gamepad.leftThumbstick,
                key: "\(controllerID).left-stick",
                inputs: stickInputs(left: true),
                controllerID: controllerID
            )
            bindStick(
                gamepad.rightThumbstick,
                key: "\(controllerID).right-stick",
                inputs: stickInputs(left: false),
                controllerID: controllerID
            )
        } else if let gamepad = controller.microGamepad {
            gamepad.allowsRotation = false
            if !usesRightJoyConHIDFallback {
                bind(gamepad.buttonA, to: .buttonA, controllerID: controllerID)
                bind(gamepad.buttonX, to: .buttonX, controllerID: controllerID)
            }
            if side(for: controller) == .right {
                let inputs = Dictionary(
                    uniqueKeysWithValues: PortraitDirection.allCases.map { direction in
                        (
                            direction,
                            SingleJoyConDirectionNormalizer.input(
                                for: direction,
                                role: .rightStick
                            )
                        )
                    }
                )
                bindStick(
                    gamepad.dpad,
                    key: "\(controllerID).right-micro-stick",
                    inputs: inputs,
                    controllerID: controllerID
                )
            } else {
                bind(gamepad.dpad.up, to: .dpadUp, controllerID: controllerID)
                bind(gamepad.dpad.down, to: .dpadDown, controllerID: controllerID)
                bind(gamepad.dpad.left, to: .dpadLeft, controllerID: controllerID)
                bind(gamepad.dpad.right, to: .dpadRight, controllerID: controllerID)
            }
        }
    }

    private func stickInputs(left: Bool) -> [PortraitDirection: ControllerInput] {
        if left {
            return [
                .up: .leftStickUp,
                .down: .leftStickDown,
                .left: .leftStickLeft,
                .right: .leftStickRight,
            ]
        }
        return [
            .up: .rightStickUp,
            .down: .rightStickDown,
            .left: .rightStickLeft,
            .right: .rightStickRight,
        ]
    }

    private func bindStick(
        _ directionPad: GCControllerDirectionPad,
        key: String,
        inputs: [PortraitDirection: ControllerInput],
        controllerID: String
    ) {
        directionPad.valueChangedHandler = { [weak self] _, xValue, yValue in
            Task { @MainActor [weak self] in
                guard self?.activeControllerID == controllerID else { return }
                self?.handleStickVector(
                    x: xValue,
                    y: yValue,
                    key: key,
                    inputs: inputs
                )
            }
        }
    }

    private func handleStickVector(
        x: Float,
        y: Float,
        key: String,
        inputs: [PortraitDirection: ControllerInput]
    ) {
        var filter = stickFilters[key] ?? StickDirectionFilter()
        let edges = filter.update(x: x, y: y)
        stickFilters[key] = filter
        for edge in edges {
            guard let input = inputs[edge.direction] else { continue }
            onEvent?(ControllerEvent(input: input, phase: edge.phase))
        }
    }

    private func bind(
        _ button: GCControllerButtonInput?,
        to input: ControllerInput,
        controllerID: String
    ) {
        button?.pressedChangedHandler = { [weak self] _, _, isPressed in
            Task { @MainActor [weak self] in
                guard self?.activeControllerID == controllerID else { return }
                self?.onEvent?(
                    ControllerEvent(
                        input: input,
                        phase: isPressed ? .pressed : .released
                    )
                )
            }
        }
    }
}
