import JoyConCodexCore
import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var model: AppModel
    @State private var confirmingReset = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                header
                outputSafetyCard
                controllerCard
                diagnosticsCard
                mappingsCard
            }
            .padding(24)
        }
        .background(Color(nsColor: .windowBackgroundColor))
        .alert("Restore starter mappings?", isPresented: $confirmingReset) {
            Button("Cancel", role: .cancel) {}
            Button("Restore", role: .destructive) {
                model.resetProfile()
            }
        } message: {
            Text("This replaces and saves every current mapping.")
        }
        .onAppear {
            model.refreshAccessibilityPermission()
        }
    }

    private var header: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Joy-Con Codex Controller")
                    .font(.largeTitle.bold())
                Text("A tactile shortcut companion for macOS")
                    .foregroundStyle(.secondary)
            }
            Spacer()
            statusPill
        }
    }

    private var statusPill: some View {
        Label(
            model.supportedControllers.isEmpty ? "Waiting for Joy-Con" : "Joy-Con ready",
            systemImage: model.supportedControllers.isEmpty
                ? "gamecontroller"
                : "gamecontroller.fill"
        )
        .padding(.horizontal, 12)
        .padding(.vertical, 7)
        .background(
            model.supportedControllers.isEmpty
                ? Color.secondary.opacity(0.14)
                : Color.green.opacity(0.18),
            in: Capsule()
        )
    }

    private var outputSafetyCard: some View {
        GroupBox {
            VStack(alignment: .leading, spacing: 12) {
                Toggle(isOn: $model.testMode) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(model.testMode ? "Test mode" : "Live shortcut output")
                            .font(.headline)
                        Text(
                            model.testMode
                                ? "Inputs resolve visibly; keyboard output is blocked."
                                : "Mapped presses control the frontmost application with keyboard shortcuts."
                        )
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    }
                }

                Divider()

                keyboardPermissionStatus
            }
            .padding(6)
        } label: {
            Label("Output safety", systemImage: "lock.shield")
        }
    }

    private var keyboardPermissionStatus: some View {
        HStack {
            Label(
                model.accessibilityTrusted
                    ? "Accessibility permission granted"
                    : "Accessibility permission required for keyboard output",
                systemImage: model.accessibilityTrusted
                    ? "checkmark.shield.fill"
                    : "exclamationmark.shield"
            )
            .foregroundStyle(model.accessibilityTrusted ? Color.green : Color.orange)
            Spacer()
            Button("Request / Refresh") {
                model.requestAccessibilityPermission()
            }
        }
    }

    private var controllerCard: some View {
        GroupBox {
            VStack(alignment: .leading, spacing: 12) {
                if model.controllers.isEmpty {
                    Text(
                        "Pair the Joy-Con in System Settings → Bluetooth, then rescan. "
                            + "This app discovers controllers already exposed by macOS."
                    )
                    .foregroundStyle(.secondary)
                } else {
                    ForEach(model.controllers) { controller in
                        HStack {
                            Image(
                                systemName: controller.isSupported
                                    ? "gamecontroller.fill"
                                    : "questionmark.app"
                            )
                            VStack(alignment: .leading) {
                                Text(controller.name)
                                    .font(.headline)
                                Text(
                                    controller.isSupported
                                        ? "\(controller.side.rawValue) · \(controller.profile)"
                                        : "\(controller.productCategory) · Unsupported"
                                )
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            }
                            Spacer()
                            Text(controller.isSupported ? "Active" : "Ignored")
                                .foregroundStyle(
                                    controller.isSupported ? Color.green : Color.secondary
                                )
                        }
                    }
                }

                HStack {
                    Button {
                        model.rescan()
                    } label: {
                        Label("Rescan", systemImage: "arrow.clockwise")
                    }
                    Spacer()
                    Text(model.statusMessage)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                }
            }
            .padding(6)
        } label: {
            Label("Controller", systemImage: "dot.radiowaves.left.and.right")
        }
    }

    private var diagnosticsCard: some View {
        GroupBox {
            HStack(alignment: .top, spacing: 24) {
                diagnostic(
                    title: "Recent input",
                    value: recentInputText,
                    symbol: "button.programmable"
                )
                Divider()
                diagnostic(
                    title: "Resolved action",
                    value: recentActionText,
                    symbol: "keyboard"
                )
                Divider()
                diagnostic(
                    title: "Feedback",
                    value: model.feedbackMessage,
                    symbol: "waveform"
                )
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(6)
        } label: {
            Label("Test and diagnostics", systemImage: "stethoscope")
        }
    }

    private var mappingsCard: some View {
        GroupBox {
            VStack(spacing: 12) {
                HStack {
                    Text(model.profile.name)
                        .font(.headline)
                    Text("Schema \(model.profile.schemaVersion)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Spacer()
                    Button("Import…") {
                        model.importProfile()
                    }
                    Button("Export…") {
                        model.exportProfile()
                    }
                    Button("Restore Defaults") {
                        confirmingReset = true
                    }
                }

                Divider()

                LazyVStack(spacing: 0) {
                    ForEach(model.profile.mappings) { mapping in
                        MappingRow(mapping: mapping) {
                            model.update($0)
                        }
                        Divider()
                    }
                }
            }
            .padding(6)
        } label: {
            Label("Shortcut mappings", systemImage: "switch.2")
        }
    }

    private var recentInputText: String {
        guard let event = model.recentEvent else { return "Move or press a Joy-Con input." }
        return "\(event.input.displayName) · \(event.phase.rawValue)"
    }

    private var recentActionText: String {
        guard let result = model.recentResult else { return "No mapping resolved yet." }
        let action = result.action?.formatted ?? "Disabled"
        let meaning = result.functionDescription.map { " · \($0)" } ?? ""
        return "\(result.layer.rawValue): \(action)\(meaning) · \(dispositionText(result.disposition))"
    }

    private func dispositionText(_ disposition: MappingDisposition) -> String {
        switch disposition {
        case .released: "released"
        case .repeated: "held (ignored)"
        case .unmapped: "unmapped"
        case .disabled: "disabled"
        case .layerActivated: "Fn active"
        case .layerReleased: "Fn released"
        case .coalesced: "shared hold"
        case .suppressedByTestMode: "tested only"
        case .emitted: "sent"
        case let .failed(message): "blocked: \(message)"
        }
    }

    private func diagnostic(title: String, value: String, symbol: String) -> some View {
        HStack(alignment: .top) {
            Image(systemName: symbol)
                .foregroundStyle(.tint)
            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.caption.bold())
                    .foregroundStyle(.secondary)
                Text(value)
                    .lineLimit(3)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

private struct MappingRow: View {
    let mapping: InputMapping
    let onChange: (InputMapping) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(mapping.input.displayName)
                .font(.headline)

            ActionSlotEditor(
                title: "Default",
                action: mapping.primaryAction,
                fallbackAction: starterMapping?.primaryAction
            ) { action in
                update(action, layer: .primary)
            }

            ActionSlotEditor(
                title: "Fn",
                action: mapping.functionAction,
                fallbackAction: starterMapping?.functionAction
            ) { action in
                update(action, layer: .function)
            }
        }
        .padding(.vertical, 10)
    }

    private var starterMapping: InputMapping? {
        MappingProfile.starter.mapping(for: mapping.input)
    }

    private func update(_ action: MappingAction?, layer: MappingLayer) {
        var copy = mapping
        switch layer {
        case .primary:
            copy.primaryAction = action
        case .function:
            copy.functionAction = action
        }
        onChange(copy)
    }
}

private struct ActionSlotEditor: View {
    let title: String
    let action: MappingAction?
    let fallbackAction: MappingAction?
    let onChange: (MappingAction?) -> Void

    var body: some View {
        HStack(spacing: 10) {
            Toggle("", isOn: enabledBinding)
                .labelsHidden()

            Text(title)
                .font(.caption.bold())
                .foregroundStyle(.secondary)
                .frame(width: 52, alignment: .leading)

            if let action {
                if action.kind == .functionLayer {
                    Label("Function layer", systemImage: "square.stack.3d.up")
                        .frame(maxWidth: .infinity, alignment: .leading)
                } else if let shortcut = action.shortcut {
                    Picker("Behavior", selection: kindBinding) {
                        Text("Tap").tag(MappingActionKind.tap)
                        Text("Hold").tag(MappingActionKind.hold)
                    }
                    .labelsHidden()
                    .frame(width: 72)

                    Picker("Key", selection: keyCodeBinding) {
                        ForEach(KeyCatalog.options) { key in
                            Text(key.label).tag(key.keyCode)
                        }
                    }
                    .labelsHidden()
                    .frame(width: 130)

                    ForEach(KeyModifier.allCases) { modifier in
                        Toggle(modifier.symbol, isOn: modifierBinding(modifier))
                            .toggleStyle(.button)
                            .help(modifier.rawValue.capitalized)
                    }

                    Spacer()

                    VStack(alignment: .trailing, spacing: 2) {
                        Text(action.formatted)
                            .font(.system(.body, design: .monospaced))
                        if let description = CodexShortcutCatalog.description(for: shortcut) {
                            Text(description)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .frame(minWidth: 150, alignment: .trailing)
                }
            } else {
                Text("Disabled")
                    .foregroundStyle(.secondary)
                Spacer()
            }
        }
    }

    private var enabledBinding: Binding<Bool> {
        Binding(
            get: { action != nil },
            set: { enabled in
                if enabled {
                    onChange(
                        fallbackAction
                            ?? .tap(Shortcut(keyCode: 53, displayLabel: "Escape"))
                    )
                } else {
                    onChange(nil)
                }
            }
        )
    }

    private var kindBinding: Binding<MappingActionKind> {
        Binding(
            get: { action?.kind ?? .tap },
            set: { kind in
                guard let shortcut = action?.shortcut else { return }
                onChange(MappingAction(kind: kind, shortcut: shortcut))
            }
        )
    }

    private var keyCodeBinding: Binding<UInt16> {
        Binding(
            get: { action?.shortcut?.keyCode ?? 53 },
            set: { keyCode in
                guard
                    let option = KeyCatalog.option(for: keyCode),
                    var action,
                    var shortcut = action.shortcut
                else { return }
                shortcut.keyCode = option.keyCode
                shortcut.displayLabel = option.label
                action.shortcut = shortcut
                onChange(action)
            }
        )
    }

    private func modifierBinding(_ modifier: KeyModifier) -> Binding<Bool> {
        Binding(
            get: { action?.shortcut?.modifiers.contains(modifier) == true },
            set: { enabled in
                guard var action, var shortcut = action.shortcut else { return }
                if enabled {
                    shortcut.modifiers.insert(modifier)
                } else {
                    shortcut.modifiers.remove(modifier)
                }
                action.shortcut = shortcut
                onChange(action)
            }
        )
    }
}

struct SettingsView: View {
    @EnvironmentObject private var model: AppModel

    var body: some View {
        Form {
            Toggle("Launch in test mode", isOn: $model.testMode)
            LabeledContent("Profile", value: model.profile.name)
            LabeledContent(
                "Accessibility",
                value: model.accessibilityTrusted ? "Granted" : "Required"
            )
        }
    }
}
