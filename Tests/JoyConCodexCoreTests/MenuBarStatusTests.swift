import Testing
@testable import JoyConCodexCore

@Suite("Menu-bar companion status")
struct MenuBarStatusTests {
    @Test("Disconnected test mode is safe and visible")
    func disconnectedTestMode() {
        let status = MenuBarStatus(
            supportedControllerCount: 0,
            testMode: true,
            accessibilityTrusted: false
        )

        #expect(status.isControllerConnected == false)
        #expect(status.controllerSummary == "No Joy-Con connected")
        #expect(status.outputState == .testMode)
        #expect(status.outputSummary == "Test mode — shortcuts blocked")
        #expect(status.systemImage == "gamecontroller")
    }

    @Test("Connected test mode remains output-safe")
    func connectedTestMode() {
        let status = MenuBarStatus(
            supportedControllerCount: 1,
            testMode: true,
            accessibilityTrusted: true
        )

        #expect(status.controllerSummary == "1 Joy-Con connected")
        #expect(status.outputState == .testMode)
        #expect(status.systemImage == "gamecontroller.fill")
    }

    @Test("Trusted live mode reports active output")
    func trustedLiveMode() {
        let status = MenuBarStatus(
            supportedControllerCount: 2,
            testMode: false,
            accessibilityTrusted: true
        )

        #expect(status.controllerSummary == "2 Joy-Cons connected")
        #expect(status.outputState == .live)
        #expect(status.outputSummary == "Live output")
    }

    @Test("Untrusted live mode reports permission block")
    func blockedLiveMode() {
        let status = MenuBarStatus(
            supportedControllerCount: 1,
            testMode: false,
            accessibilityTrusted: false
        )

        #expect(status.outputState == .blockedByAccessibility)
        #expect(status.outputSummary.contains("Accessibility required"))
        #expect(status.systemImage == "exclamationmark.triangle.fill")
    }
}
