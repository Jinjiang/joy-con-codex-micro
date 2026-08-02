## ADDED Requirements

### Requirement: Operate without a persistent Dock icon
The system SHALL run as a menu-bar accessory without occupying a Dock position while the companion process remains active.

#### Scenario: Main window is open
- **WHEN** the application launches or the user opens the main controller window from the menu bar
- **THEN** the window is usable and the application does not add a persistent Dock icon

#### Scenario: Main window is closed
- **WHEN** the user closes the main controller window
- **THEN** the Dock remains free of the companion icon while the menu-bar item and controller monitoring remain active
