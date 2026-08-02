## ADDED Requirements

### Requirement: Provide an editable mapping profile
The system SHALL allow the user to enable or disable each mapping and select a supported key and zero or more Command, Option, Control, and Shift modifiers.

#### Scenario: User edits a mapping
- **WHEN** the user changes a mapping to a valid shortcut
- **THEN** the application updates the active profile and uses the new mapping for subsequent input

### Requirement: Persist profiles locally
The system SHALL encode the active profile as versioned JSON and SHALL write it atomically within the application’s Application Support directory.

#### Scenario: App restarts after a saved edit
- **WHEN** the application launches after a valid profile was saved
- **THEN** the application restores that profile and its enabled states

#### Scenario: Stored profile is unreadable
- **WHEN** the stored profile cannot be decoded or validated
- **THEN** the application leaves the stored file untouched, loads defaults in memory, and reports the recovery state

### Requirement: Provide starter defaults and reset
The system SHALL provide a complete default profile and SHALL allow the user to restore it after confirmation.

#### Scenario: User confirms reset
- **WHEN** the user confirms restoring default mappings
- **THEN** the active profile is replaced with validated defaults and persisted

### Requirement: Import and export profiles
The system SHALL export the active profile as JSON and SHALL import only profiles that decode and validate successfully.

#### Scenario: Valid profile is imported
- **WHEN** the user selects a compatible, valid mapping-profile JSON file
- **THEN** the application makes it active and persists it

#### Scenario: Invalid profile is imported
- **WHEN** the user selects an incompatible or invalid JSON file
- **THEN** the active profile remains unchanged and the application displays the validation error
