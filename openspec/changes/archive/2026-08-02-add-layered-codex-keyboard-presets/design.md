## Context

The current profile stores one optional-on/off `Shortcut` per normalized input. `MappingEngine` emits a complete key-down/key-up pair on the press edge and discards release edges. This is sufficient for ordinary chords but cannot implement a held dictation shortcut, internal layer keys, a disabled primary action with an enabled function action, or release cleanup.

Single Joy-Cons also expose different meanings through `GCMicroGamepad`: the left device's directional controls are treated as its physical directional pad, while the right device's directional control is the analog stick. The adapter currently maps both to the same `dpad*` identifiers, which can let right-stick drift activate left directional-button actions.

The requested layout uses only public GameController, IOKit input, CoreGraphics keyboard events, and AppKit UI. The installed ChatGPT UI screenshots are the source of truth for shortcuts: hold `Control+Shift+D` for dictation, `Command+[`/`]` for Back/Forward, `Command+Shift+[`/`]` for Previous/Next Chat, `Command+Option+B` for Side panel, `Command+J` for Bottom panel, and the other chords named in the proposal. The field-tested starter puts Previous/Next Chat on unmodified SL/SR, moves Back/Forward to the Fn layer, and uses Y/spatial-left for Delete.

## Goals / Non-Goals

**Goals:**

- Represent tap, hold, function-layer, and disabled actions without any virtual device.
- Resolve a deterministic default or Fn action from each input press.
- Guarantee one dictation key-down and one final key-up across L/R coalescing, disconnects, test mode, profile changes, and application termination.
- Normalize single-Joy-Con directions so right-stick drift cannot masquerade as the left directional buttons.
- Make the starter layout and known ChatGPT action meaning visible in the mapping UI and diagnostics.
- Decode schema-v1 profiles into schema v2 without applying new defaults over existing choices.

**Non-Goals:**

- Codex Micro emulation, virtual HID output, private protocols, RGB/status feedback, or automatic ChatGPT settings changes.
- Automatically forcing ChatGPT to the foreground or blocking shortcuts when another app is frontmost.
- Continuous arrow-key repeat while a stick remains deflected.
- Guaranteeing inputs that macOS does not expose for a particular Joy-Con/OS combination; those remain hardware-verification items.

## Decisions

### Store two explicit action slots per input

`InputMapping` will store optional `primaryAction` and `functionAction` values. `MappingAction` has a kind (`tap`, `hold`, or `functionLayer`) and an optional shortcut whose presence is validated by kind. A missing slot means Disabled. Both slots are explicit, so Y can send Delete normally but toggle the sidebar under Fn, and stick/voice actions can be deliberately duplicated across both layers.

This is preferred over special-casing input identifiers in `MappingEngine`, because imported profiles, diagnostics, UI descriptions, and future customization should all see the same data.

### Resolve the layer on the target press edge

ZL and ZR always operate as internal function-layer inputs and never emit a keyboard event. A set of currently held function inputs makes the layer active while either key remains held. The action for another input is selected when that input first transitions to pressed; later Fn changes do not retroactively change it.

### Give the emitter explicit tap/down/up phases

`ShortcutEmitting` will accept `.tap`, `.keyDown`, and `.keyUp`. Tap posts a complete pair. Hold actions post key-down for the first physical owner of a shortcut and key-up after the last owner releases it. The engine remembers the resolved hold per input and exposes `releaseAll` for lifecycle cleanup.

This keeps keyboard construction and Accessibility validation in the executable target while leaving layer and ownership behavior unit-testable in the core target.

### Migrate legacy profiles without replacing them

The profile schema becomes version 2. `ProfileStore` detects schema 1, decodes the legacy `shortcut`/`isEnabled` structure, and converts enabled entries to primary tap actions while leaving their function actions disabled. Missing inputs are still added from the starter profile. Migration occurs in memory and is persisted on the next user edit/export; Restore Defaults explicitly installs the new layout.

### Derive descriptions from exact shortcut chords

A pure `CodexShortcutCatalog` maps known chords to human-readable action labels such as New chat, Toggle sidebar, or Previous chat. Descriptions are computed rather than persisted, so editing a chord immediately updates or removes the label and custom profiles do not retain stale semantics.

### Normalize right micro-gamepad directions as stick input

For a single right Joy-Con using the micro profile, `dpad` direction callbacks will produce right-stick direction identifiers; for a single left Joy-Con they remain directional-pad identifiers. Rotation stays disabled so direction names use portrait orientation. Extended profiles retain their separate D-pad and thumbstick controls.

Stick directions use a vector edge filter with an enter threshold of 0.65 and an exit threshold of 0.35. The filter emits one press when a direction enters and one release when it exits, does not repeat while held, and releases the old direction before an opposing direction. This hysteresis reduces threshold jitter but cannot repair severe hardware drift.

### Keep the mapping editor explicit

Each input row will show Default and Fn slots. Disabled slots say Disabled rather than displaying an Escape placeholder. Tap and hold slots show their chord, activation style, and any computed ChatGPT action description. Function keys show Function layer. Editing remains limited to supported keyboard keys and modifiers; the starter's special action kinds remain visible and validated.

## Risks / Trade-offs

- [ChatGPT shortcuts can be customized or changed] → Derive labels from the currently stored chord, document the screenshot-based defaults, and keep every shortcut editable.
- [Keyboard events affect the frontmost app] → Retain test mode and explain in the UI/README that these are ordinary system keyboard events.
- [macOS can expose incomplete single-Joy-Con controls] → Normalize the profiles that are available, keep raw right-button fallback, and list left/right hardware coverage as a manual test.
- [A process can be killed before cleanup] → Release holds on all controllable lifecycle transitions; an uncatchable forced kill remains an OS-level limitation.
- [Two visible action slots make rows taller] → Use compact labeled slot lines and semantic text rather than duplicating full cards.

## Migration Plan

1. Decode and validate schema-v1 JSON through a dedicated legacy representation.
2. Return an equivalent schema-v2 profile without enabling any new default action in an existing profile.
3. Apply the new starter only for missing profile files or explicit Restore Defaults.
4. Rollback remains possible by restoring the previous source; schema-v2 files will then be rejected safely and left untouched by the older build.

## Open Questions

- Exact physical-input availability for a single left Joy-Con and portrait axis orientation still requires hardware verification on the target macOS release.
