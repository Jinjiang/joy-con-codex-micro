## Purpose

Define editing, validation, persistence, reset, import, and export behavior for Joy-Con shortcut profiles.

## Requirements

### Requirement: Provide an editable mapping profile
The system SHALL present Default and Fn action slots for each input, allow supported shortcut actions to be enabled or disabled and edited with a supported key and modifiers, and accurately distinguish tap, hold, function-layer, and disabled behavior.

#### Scenario: User edits a shortcut action
- **WHEN** the user changes an enabled Default or Fn action to a valid supported shortcut
- **THEN** the application updates the active profile, refreshes its computed function description, and uses the new action for subsequent input

#### Scenario: User views a disabled slot
- **WHEN** a Default or Fn action slot is disabled
- **THEN** the interface displays Disabled and does not present an inactive Escape placeholder as its assigned action

### Requirement: Persist profiles locally
The system SHALL encode the active profile as versioned JSON, SHALL write it atomically within the application’s Application Support directory, and SHALL migrate a valid schema-v1 shortcut profile to schema v2 without enabling new starter actions over existing entries.

#### Scenario: App restarts after a schema-v2 edit
- **WHEN** the application launches after a valid schema-v2 profile was saved
- **THEN** the application restores both Default and Fn slots and their action kinds

#### Scenario: Stored schema-v1 profile is loaded
- **WHEN** a valid schema-v1 profile contains enabled or disabled one-shot mappings
- **THEN** the application converts enabled entries to Default tap actions, preserves disabled entries as disabled, leaves Fn slots disabled, and retains the profile name

#### Scenario: Stored profile is unreadable
- **WHEN** the stored profile cannot be decoded, migrated, or validated
- **THEN** the application leaves the stored file untouched, loads defaults in memory, and reports the recovery state

### Requirement: Provide starter defaults and reset
The system SHALL provide the complete layered Codex keyboard starter profile and SHALL allow the user to restore it after confirmation without silently replacing an existing saved profile during ordinary launch.

#### Scenario: User confirms reset
- **WHEN** the user confirms restoring default mappings
- **THEN** the active profile is replaced with validated layered defaults and persisted

#### Scenario: Existing profile launches after upgrade
- **WHEN** an existing compatible profile is loaded after the application gains the new starter layout
- **THEN** its existing choices remain active until the user explicitly restores defaults

### Requirement: Import and export profiles
The system SHALL export the active profile as JSON and SHALL import only profiles that decode and validate successfully.

#### Scenario: Valid profile is imported
- **WHEN** the user selects a compatible, valid mapping-profile JSON file
- **THEN** the application makes it active and persists it

#### Scenario: Invalid profile is imported
- **WHEN** the user selects an incompatible or invalid JSON file
- **THEN** the active profile remains unchanged and the application displays the validation error
