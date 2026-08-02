## Purpose

Define the safe test workflow for observing controller input and mapping resolution without producing keyboard output.

## Requirements

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

### Requirement: Test mode reports recent input
The system SHALL display the most recent normalized input, press or release state, and resolved mapping result.

#### Scenario: Unmapped input is pressed
- **WHEN** the user presses a supported input with no enabled mapping
- **THEN** the test display identifies the input and reports that no active mapping resolved

### Requirement: First launch is safe
The system SHALL enable test mode by default when no previous application settings exist.

#### Scenario: Fresh installation launches
- **WHEN** the application launches without persisted settings
- **THEN** live shortcut output is disabled until the user explicitly turns off test mode
