## ADDED Requirements

### Requirement: Starter profile uses the agreed two-layer layout
The system SHALL provide a keyboard-only starter profile whose Default and Fn actions match the agreed single-Joy-Con layout.

#### Scenario: User restores the starter profile
- **WHEN** the user confirms Restore Defaults
- **THEN** the mappings are SL Previous chat `Command+Shift+[`, SR Next chat `Command+Shift+]`, Fn+SL Back `Command+[`, Fn+SR Forward `Command+]`, A or spatial-right Enter, B or spatial-down Escape, X or spatial-up New chat `Command+N`, and Y or spatial-left Delete

#### Scenario: User uses a modified face-position input
- **WHEN** ZL or ZR is held and the user presses A/spatial-right, B/spatial-down, X/spatial-up, or Y/spatial-left
- **THEN** the system respectively emits Toggle side panel `Command+Option+B`, Toggle bottom panel `Command+J`, Command menu `Command+Shift+P`, or Toggle sidebar `Command+B`

#### Scenario: User uses a stick direction
- **WHEN** a portrait stick direction enters its active range
- **THEN** the system emits one matching Up, Down, Left, or Right Arrow tap and does not repeat until that direction is released and entered again

#### Scenario: User presses a deliberately unused control
- **WHEN** Plus, Minus, Home, Capture, or stick press is pressed
- **THEN** no keyboard event is emitted

### Requirement: ZL and ZR operate as an internal function layer
The system SHALL make the Fn layer active while at least one of ZL or ZR is held and SHALL emit no macOS key event for either function control.

#### Scenario: Both function controls overlap
- **WHEN** ZL and ZR are both held and one of them is released
- **THEN** the Fn layer remains active until the remaining function control is released

#### Scenario: Function control is pressed after a target input
- **WHEN** a target input has already triggered its Default action and ZL or ZR is then pressed
- **THEN** the completed target action is not changed or repeated

### Requirement: L and R provide hold-to-dictate
The system SHALL use either L or R to hold `Control+Shift+D` and SHALL release the shortcut only after every held voice control is released.

#### Scenario: One voice control is held
- **WHEN** L or R is pressed and later released in live mode
- **THEN** the system posts one `Control+Shift+D` key-down on press and one matching key-up on release

#### Scenario: Voice controls overlap
- **WHEN** L and R are both held and one is released
- **THEN** the dictation shortcut remains held until the final voice control is released

### Requirement: Known shortcuts show a Codex function description
The system SHALL display a human-readable function description whenever an action chord exactly matches a known ChatGPT desktop shortcut.

#### Scenario: Mapping matches a known chord
- **WHEN** a mapping slot contains `Command+N`
- **THEN** the mapping interface identifies its function as New chat in addition to showing the chord

#### Scenario: Mapping is disabled or custom
- **WHEN** a mapping slot is disabled or its chord has no known ChatGPT meaning
- **THEN** the interface shows Disabled or the chord without inventing a Codex function description
