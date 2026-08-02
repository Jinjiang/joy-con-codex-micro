## Context

The app already owns a persistent `MenuBarExtra`, a single restorable controller window, and a shared `AppModel` that continues controller monitoring after window close. Packaged builds still use the regular application activation policy and do not declare themselves as UI-element applications, so macOS keeps a Dock icon for the life of the process. The schema-v2 starter profile currently maps spatial-up to New Chat, Fn spatial-up to Command Menu, and leaves Plus/Minus disabled.

## Goals / Non-Goals

**Goals:**

- Remove the companion's persistent Dock presence without removing its launch window or menu-bar controls.
- Keep close, reopen, Settings, and explicit Quit behavior intact under accessory activation.
- Make the new Side Chat, Close Chat, and New Chat chords visible to the mapping engine, editor, diagnostics, and tests.
- Ship consistent 0.1.1 bundle metadata and release documentation.

**Non-Goals:**

- Launch at login, automatic ChatGPT activation, or global shortcuts unrelated to Joy-Con input.
- A profile schema change or automatic replacement of saved user mappings.
- Changing other starter actions, controller normalization, hold behavior, or menu-bar status semantics.

## Decisions

### Declare and enforce accessory application behavior

The packaged `Info.plist` will set `LSUIElement` so macOS starts the bundle without a Dock icon. An `NSApplicationDelegate` will also set `.accessory` during early application launch, keeping direct SwiftPM/development runs consistent with the packaged app. The existing menu action will activate the accessory application before calling `openWindow`, so the main window can still become frontmost.

Using only `LSUIElement` was considered, but direct executable runs do not receive the packaged plist. Using only a runtime activation-policy change was also considered, but it can allow a transient Dock presence during bundle launch.

### Keep spatial symmetry for single Joy-Cons

The starter will map `X` and left D-pad Up to `Command+Option+S` in Default and `Command+W` in Fn. Both Plus and Minus will map to `Command+N`, since a user may have only the right or only the left Joy-Con connected. This extends the existing convention that equivalent physical positions have the same action.

### Treat the layout as a starter-default revision

`MappingProfile.starter`, Restore Defaults, fresh installs, and missing profile inputs will use the 0.1.1 layout. Existing schema-v2 mappings will not be overwritten because the current persistence contract protects explicit user choices. Documentation will call out Restore Defaults as the way to adopt the entire revised layout.

### Keep release version separate from profile schema

The bundle's short version will become 0.1.1 and its build number will advance. The profile remains schema 2 because its data model is unchanged; the shortcut values are data defaults rather than a serialization change.

## Risks / Trade-offs

- [Accessory applications can be harder to rediscover after closing their windows] → Keep the menu-bar icon persistent with explicit Open Controller Window, Settings, and Quit actions.
- [A direct development run and a packaged launch initialize differently] → Combine `LSUIElement` with an early `.accessory` activation policy and build-test both targets.
- [Existing users may continue seeing their saved 0.1.0 mappings] → Preserve their data intentionally and document Restore Defaults for adopting 0.1.1 defaults.
- [ChatGPT shortcuts can be customized upstream] → Keep every mapping editable and derive descriptions only from exact chords.

## Migration Plan

1. Install or launch the 0.1.1 app; the application runs as an accessory and retains its existing menu-bar state.
2. Fresh profiles receive the revised starter automatically. Existing profiles remain intact until the user edits them or chooses Restore Defaults.
3. Rollback to 0.1.0 requires no data conversion because the profile schema remains version 2.

## Open Questions

None.
