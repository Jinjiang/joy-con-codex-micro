## ADDED Requirements

### Requirement: Normalize individual Joy-Con directions by physical role
The system SHALL distinguish the left Joy-Con directional controls from the right Joy-Con analog stick before producing normalized mapping inputs.

#### Scenario: Single left Joy-Con reports a portrait direction
- **WHEN** the left Joy-Con micro profile reports a directional press
- **THEN** the adapter emits the corresponding physical directional-pad identifier used as the spatial equivalent of A, B, X, or Y

#### Scenario: Single right Joy-Con reports a portrait direction
- **WHEN** the right Joy-Con micro profile reports a directional movement
- **THEN** the adapter emits the corresponding right-stick direction identifier and does not emit a directional-pad identifier

### Requirement: Stick direction edges resist threshold jitter
The system SHALL apply separate activation and release thresholds to analog stick directions and SHALL not repeat a direction while it remains active.

#### Scenario: Stick jitters near its activation threshold
- **WHEN** a stick direction has activated and its value remains above the lower release threshold
- **THEN** the adapter emits no additional press or release edge for that direction

#### Scenario: Stick returns near center
- **WHEN** an active stick direction crosses below the release threshold
- **THEN** the adapter emits one release edge and permits a later activation to produce a new press edge
