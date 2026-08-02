## Purpose

Define the persistent macOS menu-bar status and lifecycle controls for the background Joy-Con companion.

## Requirements

### Requirement: Keep a persistent menu-bar presence
The system SHALL display a menu-bar item for as long as the companion process is running, including when no standard application window is open.

#### Scenario: User closes the last standard window
- **WHEN** the user closes the last application window using its close control
- **THEN** the companion process continues running and its menu-bar item remains available

### Requirement: Operate without a persistent Dock icon
The system SHALL run as a menu-bar accessory without occupying a Dock position while the companion process remains active.

#### Scenario: Main window is open
- **WHEN** the application launches or the user opens the main controller window from the menu bar
- **THEN** the window is usable and the application does not add a persistent Dock icon

#### Scenario: Main window is closed
- **WHEN** the user closes the main controller window
- **THEN** the Dock remains free of the companion icon while the menu-bar item and controller monitoring remain active

### Requirement: Report companion status
The menu-bar interface SHALL display supported Joy-Con connection state and SHALL distinguish test mode, live output, and live output blocked by missing Accessibility trust.

#### Scenario: Controller or output state changes
- **WHEN** Joy-Con connection, test mode, or Accessibility trust changes
- **THEN** the menu-bar status updates from the shared application state

### Requirement: Control output safety from the menu
The menu-bar interface SHALL allow the user to switch between test mode and live shortcut output without reopening the main window.

#### Scenario: User enables test mode from the menu
- **WHEN** the user selects the menu action to enable test mode
- **THEN** keyboard event posting is suppressed using the same persisted test-mode state as the main window

### Requirement: Restore application windows
The menu-bar interface SHALL provide actions to reopen the main controller window and open application Settings.

#### Scenario: Main window is closed
- **WHEN** the user selects Open Controller Window from the menu
- **THEN** the system creates or focuses the main controller window

### Requirement: Quit explicitly
The menu-bar interface SHALL provide a Quit action that terminates the companion process.

#### Scenario: User selects Quit
- **WHEN** the user selects Quit from the menu-bar interface
- **THEN** the application terminates and controller monitoring stops
