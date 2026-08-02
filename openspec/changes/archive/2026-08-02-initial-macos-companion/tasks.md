## 1. Project Foundation

- [x] 1.1 Create the Swift Package targets, native SwiftUI executable entry point, resource bundle, and test target
- [x] 1.2 Add project metadata, repository ignores, and environment documentation for Xcode, signing, Bluetooth, and Accessibility permissions

## 2. Core Models and Configuration

- [x] 2.1 Implement normalized controller input, shortcut, modifier, mapping, and versioned profile value types
- [x] 2.2 Implement default mappings, validation, atomic Application Support persistence, reset, import, and export
- [x] 2.3 Implement edge-triggered mapping resolution with a hard test-mode output gate

## 3. macOS Adapters

- [x] 3.1 Implement GameController discovery, Joy-Con classification, connection tracking, background monitoring, and normalized input callbacks
- [x] 3.2 Implement Accessibility trust reporting and CoreGraphics keyboard shortcut emission
- [x] 3.3 Implement non-blocking visual feedback state and best-effort controller haptics

## 4. Native Application UI

- [x] 4.1 Build controller status and system-pairing guidance with a rescan action
- [x] 4.2 Build mapping configuration controls with live persistence, reset, import, and export actions
- [x] 4.3 Build the test/live-output controls, permission status, and recent input/shortcut diagnostics

## 5. Verification

- [x] 5.1 Add unit tests for defaults, validation, JSON persistence, edge detection, mapping resolution, and test-mode suppression
- [x] 5.2 Run OpenSpec validation plus Swift build and test, recording hardware/Xcode verification limits in the README
