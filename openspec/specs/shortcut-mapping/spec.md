## Purpose

Define normalized Joy-Con input, edge-triggered mapping resolution, and safe macOS keyboard shortcut emission.

## Requirements

### Requirement: Normalize supported Joy-Con input
The system SHALL translate supported controller buttons, directional-pad directions, shoulder inputs, and thumbstick presses into stable application-level input identifiers.

#### Scenario: Supported button is pressed
- **WHEN** the GameController adapter reports a supported element transitioning from released to pressed
- **THEN** the mapping engine receives one normalized press event for that input identifier

#### Scenario: Button remains held
- **WHEN** repeated controller values indicate that an already pressed input remains pressed
- **THEN** the mapping engine does not produce additional shortcut activations until the input is released and pressed again

### Requirement: Resolve enabled mappings
The system SHALL resolve each normalized press event against the active profile and current internal function-layer state and SHALL ignore absent or disabled action slots.

#### Scenario: Enabled Default action exists
- **WHEN** a supported non-function input is pressed without ZL or ZR held and has a valid Default action
- **THEN** the mapping engine returns that action once

#### Scenario: Enabled Fn action exists
- **WHEN** a supported input is pressed while ZL or ZR is held and has a valid Fn action
- **THEN** the mapping engine returns the Fn action once instead of the Default action

#### Scenario: Selected action slot is disabled
- **WHEN** a supported input is pressed and the selected Default or Fn slot is disabled
- **THEN** no shortcut is emitted

### Requirement: Emit keyboard shortcut chords
The system SHALL emit tap actions as a macOS virtual-key down event followed by key-up and SHALL emit hold actions as a key-down on the controller press edge followed by key-up on the corresponding final release edge, using the configured modifier flags.

#### Scenario: Live tap output is enabled and trusted
- **WHEN** a valid tap action resolves outside test mode and Accessibility trust is available
- **THEN** the configured shortcut chord is posted once as key-down followed by key-up

#### Scenario: Live hold output is enabled and trusted
- **WHEN** a valid hold action resolves outside test mode and Accessibility trust is available
- **THEN** the configured shortcut key remains down until the last physical owner of that hold action releases

#### Scenario: Accessibility trust is unavailable
- **WHEN** a valid action resolves outside test mode but Accessibility trust is unavailable
- **THEN** no keyboard event is posted and the application reports the permission requirement

### Requirement: Fail safely
The system SHALL reject actions with an unsupported action kind, unsupported key code, missing shortcut data, empty label, or inconsistent modifier data and SHALL never report a partial tap chord as successful.

#### Scenario: Invalid imported action
- **WHEN** profile validation encounters an invalid action or shortcut
- **THEN** the mapping is rejected with a user-visible validation error and no event is posted

### Requirement: Held output is released during lifecycle changes
The system SHALL release every keyboard hold that it previously emitted when the controller disconnects, the profile changes, test mode begins, or the application terminates.

#### Scenario: Controller disconnects during dictation
- **WHEN** the active Joy-Con disconnects while a dictation hold is active
- **THEN** the system posts one matching key-up and clears controller, layer, and ownership state
