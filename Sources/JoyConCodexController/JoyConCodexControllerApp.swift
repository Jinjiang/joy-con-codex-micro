import AppKit
import SwiftUI

enum AppSceneID {
    static let mainWindow = "main-controller-window"
}

final class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationWillFinishLaunching(_ notification: Notification) {
        NSApplication.shared.setActivationPolicy(.accessory)
    }
}

@main
struct JoyConCodexControllerApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    @StateObject private var model = AppModel()

    var body: some Scene {
        Window("Joy-Con Codex Controller", id: AppSceneID.mainWindow) {
            ContentView()
                .environmentObject(model)
                .frame(minWidth: 1_040, minHeight: 760)
        }
        .windowStyle(.titleBar)

        MenuBarExtra {
            MenuBarCompanionView()
                .environmentObject(model)
        } label: {
            Image(systemName: model.menuBarStatus.systemImage)
                .accessibilityLabel("Joy-Con Codex Controller")
        }
        .menuBarExtraStyle(.menu)

        Settings {
            SettingsView()
                .environmentObject(model)
                .frame(width: 460)
                .padding()
        }
    }
}
