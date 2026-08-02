## ADDED Requirements

### Requirement: Normalize supported Joy-Con input
The system SHALL translate supported controller buttons, directional-pad directions, shoulder inputs, and thumbstick presses into stable application-level input identifiers.

#### Scenario: Supported button is pressed
- **WHEN** the GameController adapter reports a supported element transitioning from released to pressed
- **THEN** the mapping engine receives one normalized press event for that input identifier

#### Scenario: Button remains held
- **WHEN** repeated controller values indicate that an already pressed input remains pressed
- **THEN** the mapping engine does not produce additional shortcut activations until the input is released and pressed again

### Requirement: Resolve enabled mappings
The system SHALL resolve each normalized press event against the active profile and SHALL ignore absent or disabled mappings.

#### Scenario: Enabled mapping exists
- **WHEN** a supported input is pressed and has an enabled valid shortcut mapping
- **THEN** the mapping engine returns that shortcut once

#### Scenario: Mapping is disabled
- **WHEN** a supported input is pressed and its mapping is disabled
- **THEN** no shortcut is emitted

### Requirement: Emit keyboard shortcut chords
The system SHALL emit a resolved shortcut as a macOS virtual-key down event followed by a key-up event with the configured modifier flags.

#### Scenario: Live output is enabled and trusted
- **WHEN** a valid mapping resolves outside test mode and Accessibility trust is available
- **THEN** the configured shortcut chord is posted once to the active macOS session

#### Scenario: Accessibility trust is unavailable
- **WHEN** a valid mapping resolves outside test mode but Accessibility trust is unavailable
- **THEN** no keyboard event is posted and the application reports the permission requirement

### Requirement: Fail safely
The system SHALL reject shortcuts with unsupported key codes, empty labels, or inconsistent modifier data and SHALL never post a partial chord.

#### Scenario: Invalid imported shortcut
- **WHEN** profile validation encounters an invalid shortcut
- **THEN** the mapping is rejected with a user-visible validation error and no event is posted
