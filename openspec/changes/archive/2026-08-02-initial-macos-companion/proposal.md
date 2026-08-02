## Why

Codex users need a practical, tactile shortcut controller that does not depend on dedicated Codex Micro hardware. A Nintendo Switch Joy-Con is widely available, compact, wireless, and has enough distinct inputs to make common Codex actions accessible without leaving the keyboard workflow.

## What Changes

- Add a standalone native macOS companion app that observes already paired Nintendo Switch Joy-Con controllers and reports connection state.
- Add configurable mappings from supported Joy-Con inputs to macOS keyboard shortcuts.
- Persist user mappings locally and provide sensible starter mappings that can be restored.
- Add an in-app test mode that visualizes input and shortcut resolution without posting keyboard events.
- Add basic, best-effort Joy-Con feedback for connection and mapping events when supported by the connected controller.
- Document macOS Bluetooth, Accessibility/Input Monitoring, signing, and local build requirements.
- Keep rich live Codex agent lighting/status integration out of this initial release; treat it as an optional future phase.

## Capabilities

### New Capabilities

- `controller-detection`: Discover supported Joy-Con devices exposed by macOS, distinguish left/right controllers, and surface connection health.
- `shortcut-mapping`: Resolve Joy-Con button and stick inputs to user-defined keyboard shortcut chords and safely emit them on macOS.
- `profile-configuration`: Edit, validate, persist, reset, import, and export the local mapping profile.
- `input-test-mode`: Inspect raw controller inputs and resolved mappings without sending keyboard events.
- `basic-controller-feedback`: Provide conservative, best-effort connection or mapping feedback using capabilities available through supported system frameworks.

### Modified Capabilities

None.

## Impact

- Introduces a Swift 6 native macOS SwiftUI executable and supporting library targets.
- Uses Apple GameController for Joy-Con discovery/input, CoreGraphics for keyboard event posting, and Foundation for local configuration.
- Requires Bluetooth pairing to be completed in macOS System Settings; the app does not implement a custom Bluetooth pairing stack.
- Posting shortcuts requires macOS Accessibility permission. Input Monitoring may also be required depending on OS policy and distribution/signing context.
- No network service, Codex API dependency, or live per-agent state integration is included in the initial scope.
