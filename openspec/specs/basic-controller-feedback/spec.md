## Purpose

Define the visual and best-effort haptic feedback supplied for controller connection and mapping activity.

## Requirements

### Requirement: Always provide visual controller feedback
The system SHALL visually indicate controller connection changes and successfully resolved input mappings.

#### Scenario: Joy-Con connects
- **WHEN** a supported Joy-Con becomes active
- **THEN** the interface displays a connected confirmation without requiring haptic support

#### Scenario: Mapping resolves
- **WHEN** a controller input resolves to an enabled shortcut
- **THEN** the interface briefly identifies the activated input and shortcut

### Requirement: Use haptics only when supported
The system SHALL treat controller haptics as optional and SHALL attempt only a brief conservative confirmation when GameController reports a supported haptic locality.

#### Scenario: Controller exposes supported haptics
- **WHEN** feedback is requested and the active controller reports a supported default haptic locality
- **THEN** the application attempts one brief confirmation pattern

#### Scenario: Controller lacks haptics
- **WHEN** feedback is requested and the active controller does not expose supported haptics
- **THEN** input handling continues normally with visual feedback only

### Requirement: Feedback failure is non-blocking
The system SHALL isolate haptic setup or playback failures from connection tracking and shortcut mapping.

#### Scenario: Haptic playback fails
- **WHEN** the feedback adapter cannot create or start a haptic engine
- **THEN** the application records a non-fatal feedback status and continues processing controller input
