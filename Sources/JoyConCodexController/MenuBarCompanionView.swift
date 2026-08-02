import AppKit
import JoyConCodexCore
import SwiftUI

struct MenuBarCompanionView: View {
    @Environment(\.openWindow) private var openWindow
    @EnvironmentObject private var model: AppModel

    private var status: MenuBarStatus {
        model.menuBarStatus
    }

    var body: some View {
        Group {
            Label(
                status.controllerSummary,
                systemImage: status.isControllerConnected
                    ? "gamecontroller.fill"
                    : "gamecontroller"
            )
            .disabled(true)

            Label(status.outputSummary, systemImage: outputSystemImage)
                .disabled(true)

            Divider()

            Toggle("Test Mode", isOn: $model.testMode)

            Divider()

            Button {
                NSApplication.shared.activate(ignoringOtherApps: true)
                openWindow(id: AppSceneID.mainWindow)
            } label: {
                Label("Open Controller Window", systemImage: "macwindow")
            }

            SettingsLink {
                Label("Settings…", systemImage: "gearshape")
            }

            Divider()

            Button {
                NSApplication.shared.terminate(nil)
            } label: {
                Label("Quit Joy-Con Codex Controller", systemImage: "power")
            }
            .keyboardShortcut("q")
        }
        .onAppear {
            model.refreshAccessibilityPermission()
        }
    }

    private var outputSystemImage: String {
        switch status.outputState {
        case .testMode:
            "checkmark.shield"
        case .live:
            "keyboard.fill"
        case .blockedByAccessibility:
            "exclamationmark.shield"
        }
    }
}
