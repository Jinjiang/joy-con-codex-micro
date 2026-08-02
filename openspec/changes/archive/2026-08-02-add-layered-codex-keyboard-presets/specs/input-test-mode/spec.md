## MODIFIED Requirements

### Requirement: Test mode prevents shortcut output
The system SHALL provide a test mode in which normalized controller events, function-layer state, and action resolution remain visible while tap, key-down, and key-up output for actions that begin in test mode are disabled.

#### Scenario: Mapped tap input is pressed in test mode
- **WHEN** the user presses an input that resolves to a tap action while test mode is enabled
- **THEN** the application displays the input, layer, resolved shortcut, and function description and posts no keyboard event

#### Scenario: Hold input is pressed and released in test mode
- **WHEN** the user presses and releases an input that resolves to a hold action while test mode is enabled
- **THEN** the application displays both edges and posts neither key-down nor key-up

#### Scenario: Test mode begins during live held output
- **WHEN** the user enables test mode while a hold action is active
- **THEN** the application emits the required final key-up before suppressing subsequent output
