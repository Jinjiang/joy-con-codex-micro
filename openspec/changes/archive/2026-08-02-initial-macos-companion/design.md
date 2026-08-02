## Context

This is a greenfield native macOS companion. macOS owns Bluetooth pairing and exposes compatible Joy-Con devices through GameController. The app must continue receiving controller events when another application, such as Codex, is frontmost, translate edge-triggered inputs into configured shortcut chords, and post those chords only with explicit user permission. The first release must remain useful without any Codex API or agent-status integration.

The available bootstrap environment has Swift 6.3 and Apple Command Line Tools, but not a selected full Xcode installation. The project therefore uses Swift Package Manager as its portable source-of-truth and can be built at the command line now or opened directly in Xcode later.

## Goals / Non-Goals

**Goals:**

- Provide a native SwiftUI macOS interface for controller status, mappings, permission health, and testing.
- Detect already paired Joy-Con controllers through public Apple frameworks and handle connect/disconnect transitions.
- Represent mapping and shortcut logic in a framework-independent core that can be unit tested without hardware.
- Post safe, discrete keyboard shortcut chords only on button-down edges and only outside test mode.
- Persist configuration locally with deterministic defaults and validation.
- Provide basic, best-effort feedback without making controller haptics a hard dependency.

**Non-Goals:**

- Implementing Bluetooth pairing, raw HID drivers, Joy-Con firmware protocols, motion controls, analog gesture sequences, or controller calibration.
- Guaranteeing Nintendo-specific rumble or LED behavior across macOS/controller firmware combinations.
- Reading Codex state, tracking individual agents, or displaying rich live agent status through controller lighting.
- Distributing, notarizing, or publishing the app in this change.

## Decisions

### Use a Swift Package with a SwiftUI executable

The repository will contain a `JoyConCodexCore` library, a `JoyConCodexController` executable, and unit tests. SwiftPM keeps the project buildable with the installed command-line toolchain and remains directly openable by Xcode.

Alternative considered: commit a hand-authored `.xcodeproj`. This was rejected because project-file generation is brittle without full Xcode or XcodeGen and would make the bootstrap depend on tooling that is not installed.

### Use GameController rather than raw IOKit HID

`GCController.controllers()`, connect/disconnect notifications, and wireless discovery provide the public framework boundary. The adapter will inspect extended and micro gamepad profiles and translate known elements into stable app-level `ControllerInput` identifiers. Background delivery will be requested with `GCController.shouldMonitorBackgroundEvents`.

Alternative considered: read Joy-Con HID reports directly. This could expose more Nintendo-specific features, but it adds device-protocol maintenance, broader permissions, and App Sandbox/distribution risk that are inappropriate for the first release.

### Treat macOS pairing as an external prerequisite

The connection UI will explain how to pair in System Settings and offer a rescan action. “Pairing” in the app means discovering a device macOS has already paired or connected; the app will not claim to own the Bluetooth pairing transaction.

### Separate input resolution from side effects

The controller adapter publishes normalized press/release events. A mapping engine performs edge detection and resolves enabled mappings. A `ShortcutEmitting` protocol owns side effects, with a CoreGraphics implementation for production and a recording implementation for tests.

This prevents button-repeat storms, makes test mode a hard gate around event posting, and allows deterministic unit tests.

### Store explicit key codes and modifier sets

A `Shortcut` contains a macOS virtual key code, a display label, and a normalized set of Command/Option/Control/Shift modifiers. The emitter posts modifiers on the key events, sends key-down followed by key-up, and refuses incomplete or invalid shortcuts.

Alternative considered: save free-form shortcut strings and parse them at emission time. Explicit typed data gives better validation and avoids locale-dependent parsing.

### Persist a versioned JSON profile in Application Support

The active `MappingProfile` is Codable and schema-versioned. It is stored atomically under the app’s Application Support directory. Decode or validation failure leaves the damaged file untouched, reports the problem, and loads defaults in memory. Import/export use the same validated format.

`UserDefaults` was considered but rejected because a versioned document is easier to inspect, test, export, and migrate.

### Make test mode a first-class safety state

Test mode shows the most recent normalized input and resolved shortcut, but never calls the production shortcut emitter. It is enabled by default on first launch so the user can verify mappings before granting control of keyboard input.

### Use best-effort feedback

The app always supplies visual feedback. When GameController exposes a supported haptic locality, the adapter may play a brief conservative confirmation pattern; unsupported devices silently retain visual feedback. Haptics failure never blocks input handling.

### Keep UI state on the main actor

Controller callbacks are funneled onto the main actor before mutating observable state. Persistence and mapping types remain Sendable value types where practical.

## Risks / Trade-offs

- [Joy-Con exposure varies by macOS version, firmware, and whether controllers are used separately or as a pair] → Detect capabilities dynamically, show product/profile details, and avoid claiming support for unavailable elements.
- [Background controller delivery may behave differently under App Sandbox or future macOS policy] → Use the public background-monitoring switch and document tested distribution constraints.
- [Synthetic shortcuts can control any frontmost app] → Require explicit Accessibility trust, default to test mode, show a prominent live-output state, and never record keyboard input.
- [Virtual key codes are keyboard-layout-sensitive] → Store a display label alongside the hardware-oriented key code and validate it; richer layout-aware capture can be a later enhancement.
- [Haptics may not be exposed for Joy-Con] → Make feedback optional and keep connection/mapping behavior independent.
- [Full GUI signing and entitlements cannot be verified without Xcode] → Keep CLI build/test green and document Xcode as a release prerequisite.

## Migration Plan

1. Ship schema version 1 with a bundled default profile.
2. On first launch, create the Application Support directory and save defaults only after the first edit or explicit reset.
3. For future schema versions, decode by version and migrate a copy before replacing the active file.
4. Roll back by replacing the executable; user profiles remain standalone JSON and can be reset or exported.

## Open Questions

- Which macOS and Joy-Con firmware combinations expose haptics reliably through GameController?
- Should a later release add layout-aware shortcut capture instead of the initial key-code picker?
- Should rich Codex status integration use a local Codex event source, a plugin, or a separate opt-in bridge? This remains outside the initial change.
