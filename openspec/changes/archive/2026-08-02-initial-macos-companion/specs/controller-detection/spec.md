## ADDED Requirements

### Requirement: Detect supported controllers
The system SHALL enumerate controllers exposed by the macOS GameController framework and SHALL identify devices whose vendor name or product category indicates a Nintendo Joy-Con.

#### Scenario: Joy-Con is already connected at launch
- **WHEN** the application finishes starting and macOS exposes a connected Joy-Con
- **THEN** the application displays that controller as connected with its available identity and profile information

#### Scenario: Non-Joy-Con controller is connected
- **WHEN** macOS exposes a controller that cannot be identified as a Joy-Con
- **THEN** the application lists it as unsupported and does not enable shortcut output for it

### Requirement: Track connection changes
The system SHALL update controller state in response to GameController connect and disconnect notifications.

#### Scenario: Joy-Con connects while the app is open
- **WHEN** macOS posts a controller-connect notification for a Joy-Con
- **THEN** the application attaches input handlers and changes the displayed state to connected

#### Scenario: Active Joy-Con disconnects
- **WHEN** macOS posts a disconnect notification for the active Joy-Con
- **THEN** the application removes its handlers, stops resolving its input, and displays the disconnected state

### Requirement: Guide system-owned pairing
The system SHALL explain that Bluetooth pairing is completed in macOS System Settings and SHALL provide a rescan action using public controller discovery APIs.

#### Scenario: No Joy-Con is available
- **WHEN** no supported controller is detected
- **THEN** the application displays pairing guidance and offers to rescan

### Requirement: Observe background controller input
The system SHALL request GameController background event monitoring so mappings can work while Codex or another application is frontmost.

#### Scenario: App loses foreground focus
- **WHEN** a supported Joy-Con is connected and the app is no longer frontmost
- **THEN** eligible controller input continues to reach the mapping engine subject to macOS policy and granted permissions
