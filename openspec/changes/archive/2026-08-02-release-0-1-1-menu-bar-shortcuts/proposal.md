## Why

Joy-Con Codex Controller is a background companion, so retaining a permanent Dock slot after its configuration window closes makes the app feel heavier than its role requires. The most frequently used starter actions should also prioritize opening and closing Side Chats while keeping New Chat reachable from either a left or right Joy-Con.

## What Changes

- Run the application as a menu-bar accessory without a persistent Dock icon while keeping its main window available at launch and from the menu bar.
- Keep controller monitoring and shortcut output active after the main window closes until the user explicitly quits.
- Change the starter spatial-up action (`X` on the right Joy-Con or D-pad Up on the left) to New Side Chat using `Command+Option+S`.
- Change the Fn spatial-up action from Command Menu to Close Chat using `Command+W`.
- Assign New Chat using `Command+N` to both Plus and Minus so either single Joy-Con can create a chat.
- Prepare the bundled application metadata and documentation for version 0.1.1.

## Capabilities

### New Capabilities

None.

### Modified Capabilities

- `menu-bar-companion`: The companion becomes a Dockless menu-bar accessory while retaining explicit window restoration and quit behavior.
- `layered-keyboard-presets`: The starter layout prioritizes New Side Chat, Close Chat, and New Chat on revised inputs.

## Impact

The change affects the SwiftUI/AppKit application lifecycle, packaged `Info.plist`, starter profile and known shortcut catalog, unit tests, release metadata, and user-facing mapping documentation. It adds no external dependency and does not change the profile schema or overwrite saved custom profiles.
