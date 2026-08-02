import SwiftUI

enum AppSceneID {
    static let mainWindow = "main-controller-window"
}

@main
struct JoyConCodexControllerApp: App {
    @StateObject private var model = AppModel()

    var body: some Scene {
        Window("Joy-Con Codex Controller", id: AppSceneID.mainWindow) {
            ContentView()
                .environmentObject(model)
                .frame(minWidth: 840, minHeight: 680)
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
