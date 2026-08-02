## Context

The app already remains alive after its last window closes because the SwiftUI lifecycle does not terminate on window close. That behavior supports background Joy-Con mappings, but there is no persistent UI surface to communicate that the controller listener is still active or to reopen and quit the app.

## Goals / Non-Goals

**Goals:**

- Keep the companion process and controller monitoring active after standard windows close.
- Provide a persistent menu-bar item with connection and output-safety status.
- Make reopening the main window, opening Settings, toggling test mode, and quitting explicit.
- Reuse the existing observable application state so the window and menu cannot disagree.

**Non-Goals:**

- Converting the app to a menu-bar-only accessory without a Dock presence.
- Adding launch-at-login, notifications, global hotkeys, or Codex agent-state integration.
- Changing controller input, mapping, persistence, or shortcut-emission semantics.

## Decisions

### Add a SwiftUI MenuBarExtra scene

The app will add a `MenuBarExtra` alongside its existing `WindowGroup` and `Settings` scenes. The menu label and content will observe the same `AppModel`, giving it live connection, test-mode, and Accessibility state without a second lifecycle controller.

Alternative considered: create an `NSStatusItem` in an AppKit application delegate. `MenuBarExtra` is sufficient for the required menu and keeps scene composition in SwiftUI.

### Give the main Window scene a stable identifier

The main scene will use SwiftUI’s single-instance `Window` scene with a stable ID. A dedicated menu view will call SwiftUI’s `openWindow` action with that ID, providing a supported way to recreate or focus the main window after the red close button removes it without creating duplicate configuration windows.

### Keep close and quit intentionally distinct

Closing the last window will keep the process alive and the menu-bar item visible. The menu will expose an explicit Quit action that calls `NSApplication.terminate`, which tears down the process and controller callbacks.

Alternative considered: terminate after the last window closes. This conflicts with the selected background-companion behavior.

### Derive concise menu status from application state

The menu will report whether a supported Joy-Con is connected and whether output is in test or live mode. Live mode without Accessibility trust will be visibly marked as blocked. The status calculation will be represented as a small pure value type so it can be unit tested.

## Risks / Trade-offs

- [Users may still mistake window close for quit] → Label the menu with persistent status and document Close versus Quit.
- [A live-output process can keep sending shortcuts without a window] → Keep output mode visible and provide a one-click switch back to test mode.
- [Window restoration could fail to foreground the app] → Activate the application before requesting the stable main window.
- [MenuBarExtra requires macOS 13 or newer] → The project already targets macOS 14.
