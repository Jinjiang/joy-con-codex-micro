## Why

Closing the app’s last window leaves the controller process running, which is appropriate for a background companion but currently gives the user no visible status or reliable way to reopen or quit it. A persistent menu-bar presence makes that lifecycle explicit and controllable.

## What Changes

- Add a persistent macOS menu-bar item while the companion process is running.
- Show Joy-Con connection and test/live-output status in the menu.
- Provide actions to reopen the main controller window, toggle test mode, open Settings, and quit the application.
- Keep closing the last standard window non-terminating so controller mappings can continue in the background.
- Document the intended close-versus-quit behavior.

## Capabilities

### New Capabilities

- `menu-bar-companion`: Expose background-running status and lifecycle controls through a persistent macOS menu-bar item.

### Modified Capabilities

None.

## Impact

- Updates the SwiftUI scene composition and adds a menu-bar view.
- Reuses the existing `AppModel`; no new network service, dependency, or controller protocol is introduced.
- Adds lifecycle/UI tests where behavior can be represented independently of AppKit windows.
