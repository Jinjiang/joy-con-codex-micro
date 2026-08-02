## 1. Mapping model and profile compatibility

- [x] 1.1 Add tap, hold, and function-layer actions with explicit Default and Fn slots
- [x] 1.2 Add bracket key support, the screenshot-based layered starter profile, and computed ChatGPT shortcut descriptions
- [x] 1.3 Migrate schema-v1 profiles to schema v2 without applying new defaults over existing mappings
- [x] 1.4 Extend profile validation and persistence tests for action kinds, layered defaults, descriptions, and legacy migration

## 2. Layer and keyboard lifecycle

- [x] 2.1 Extend shortcut emission to support tap, key-down, and key-up phases
- [x] 2.2 Implement ZL/ZR function-layer resolution and press-edge action selection
- [x] 2.3 Implement coalesced L/R hold-to-dictate ownership and release-all cleanup
- [x] 2.4 Wire cleanup into test mode, controller disconnect, profile changes, reset/import, and application termination
- [x] 2.5 Add mapping-engine tests for layered resolution, overlapping function keys, hold ownership, failure, and test-mode suppression

## 3. Joy-Con direction normalization

- [x] 3.1 Normalize left micro-gamepad directions as directional buttons and right micro-gamepad directions as right-stick inputs
- [x] 3.2 Add hysteretic edge filtering for extended-profile stick directions and unit tests for jitter and opposing directions

## 4. Interface and documentation

- [x] 4.1 Update mapping rows and diagnostics to show Default/Fn behavior, Disabled state, hold/layer types, and computed ChatGPT function descriptions
- [x] 4.2 Update README with the complete keyboard-only layout, foreground-app warning, migration behavior, and hardware verification limits
- [x] 4.3 Run Swift build/tests and strict OpenSpec validation, then record all tasks complete

## 5. Field-tested preset refinements

- [x] 5.1 Make Y/spatial-left send Delete by default and swap the SL/SR Default and Fn actions
- [x] 5.2 Update preset documentation and regression tests for the refined layout
- [x] 5.3 Run Swift build/tests and strict OpenSpec validation
