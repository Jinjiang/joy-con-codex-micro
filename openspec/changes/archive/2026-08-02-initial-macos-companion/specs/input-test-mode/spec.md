## ADDED Requirements

### Requirement: Test mode prevents shortcut output
The system SHALL provide a test mode in which normalized controller events and mapping resolution remain active while keyboard event posting is disabled.

#### Scenario: Mapped input is pressed in test mode
- **WHEN** the user presses an input that resolves to a shortcut while test mode is enabled
- **THEN** the application displays the input and resolved shortcut and posts no keyboard event

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
