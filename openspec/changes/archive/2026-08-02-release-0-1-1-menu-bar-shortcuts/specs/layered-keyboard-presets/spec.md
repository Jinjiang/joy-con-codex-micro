## MODIFIED Requirements

### Requirement: Starter profile uses the agreed two-layer layout
The system SHALL provide a keyboard-only starter profile whose Default and Fn actions match the agreed single-Joy-Con layout.

#### Scenario: User restores the starter profile
- **WHEN** the user confirms Restore Defaults
- **THEN** the mappings are SL Previous chat `Command+Shift+[`, SR Next chat `Command+Shift+]`, Fn+SL Back `Command+[`, Fn+SR Forward `Command+]`, A or spatial-right Enter, B or spatial-down Escape, X or spatial-up New Side Chat `Command+Option+S`, Y or spatial-left Delete, and Plus or Minus New Chat `Command+N`

#### Scenario: User uses a modified face-position input
- **WHEN** ZL or ZR is held and the user presses A/spatial-right, B/spatial-down, X/spatial-up, or Y/spatial-left
- **THEN** the system respectively emits Toggle side panel `Command+Option+B`, Toggle bottom panel `Command+J`, Close Chat `Command+W`, or Toggle sidebar `Command+B`

#### Scenario: User uses a stick direction
- **WHEN** a portrait stick direction enters its active range
- **THEN** the system emits one matching Up, Down, Left, or Right Arrow tap and does not repeat until that direction is released and entered again

#### Scenario: User presses a deliberately unused control
- **WHEN** Home, Capture, or stick press is pressed
- **THEN** no keyboard event is emitted

### Requirement: Known shortcuts show a Codex function description
The system SHALL display a human-readable function description whenever an action chord exactly matches a known ChatGPT desktop shortcut.

#### Scenario: Mapping matches a known chat chord
- **WHEN** a mapping slot contains `Command+N`, `Command+Option+S`, or `Command+W`
- **THEN** the mapping interface respectively identifies its function as New chat, New side chat, or Close chat in addition to showing the chord

#### Scenario: Mapping is disabled or custom
- **WHEN** a mapping slot is disabled or its chord has no known ChatGPT meaning
- **THEN** the interface shows Disabled or the chord without inventing a Codex function description
