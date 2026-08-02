## Why

The current starter profile is a flat collection of one-shot shortcuts and cannot express the agreed single-Joy-Con workflow: a held dictation key, a ZL/ZR function layer, side-aware face-button equivalents, or clear Codex action descriptions. A safer keyboard-only preset should match the shortcuts visible in the installed ChatGPT app while minimizing stick-drift and wrong-application hazards.

## What Changes

- Replace the starter layout with a two-layer, single-Joy-Con-oriented Codex keyboard preset.
- Treat ZL and ZR as an internal function-layer modifier that never posts a macOS key event.
- Treat L and R as hold-to-dictate controls that hold `Control+Shift+D` until every held voice control is released.
- Map SL/SR to Previous/Next Chat and, while the function layer is held, app Back/Forward.
- Map the right Joy-Con face buttons and the spatially equivalent left Joy-Con directions to Enter, Escape, New Chat, or Delete, with a second set of panel, command-menu, and sidebar actions on the function layer.
- Map portrait stick directions to one edge-triggered arrow-key tap, while keeping Plus, Minus, Home, Capture, and stick press disabled by default.
- Distinguish a single left Joy-Con directional pad from a single right Joy-Con stick before applying mappings, and add conservative direction hysteresis so stick drift does not repeatedly retrigger actions.
- Show a human-readable Codex function description beside shortcuts whose meaning is known.
- Preserve existing saved profiles; the new starter is applied on first launch or when the user explicitly restores defaults.

## Capabilities

### New Capabilities
- `layered-keyboard-presets`: Defines the keyboard-only starter layout, function-layer resolution, hold-to-dictate lifecycle, and Codex action descriptions.

### Modified Capabilities
- `shortcut-mapping`: Extend mappings beyond one-shot chords to disabled, tap, hold, and function-layer behavior with safe release handling.
- `controller-detection`: Normalize single left/right Joy-Con controls by physical side and portrait direction, with drift-resistant stick edges.
- `profile-configuration`: Persist the expanded mapping schema, retain existing profiles safely, and present disabled mappings and Codex function descriptions accurately.
- `input-test-mode`: Suppress both tap and hold output and safely release any held shortcut when test mode begins.

## Impact

- Core mapping/profile models, validation, migration, mapping engine, and keyboard emitter.
- GameController and raw-HID normalization for individual left and right Joy-Con devices.
- Main-window mapping rows, diagnostics, README documentation, and automated tests.
- No virtual HID device, private Codex protocol, network integration, or Codex Micro compatibility code is introduced.
