import JoyConCodexCore
import SwiftUI

struct JoyConDiagramView: View {
    let selectedInput: ControllerInput?
    let activeInput: ControllerInput?
    let onSelect: (ControllerInput) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .firstTextBaseline) {
                VStack(alignment: .leading, spacing: 3) {
                    Text("Joy-Con layout")
                        .font(.headline)
                    Text("Portrait orientation · Plus / Minus at the top")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                if let selectedInput {
                    Text(selectedInput.displayName)
                        .font(.caption.bold())
                        .padding(.horizontal, 9)
                        .padding(.vertical, 5)
                        .background(Color.accentColor.opacity(0.14), in: Capsule())
                }
            }

            GeometryReader { proxy in
                let width = min(proxy.size.width, proxy.size.height * 1.18)
                let size = CGSize(width: width, height: width / 1.18)

                ZStack {
                    bodies(in: size)
                    shoulderButtons(in: size)
                    leftControls(in: size)
                    rightControls(in: size)
                    railButtons(in: size)
                }
                .animation(.easeInOut(duration: 0.16), value: selectedInput)
                .animation(.easeInOut(duration: 0.12), value: activeInput)
                .frame(width: size.width, height: size.height)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            HStack(spacing: 16) {
                legend(color: .yellow, text: "Selected mapping")
                legend(color: .green, text: "Live input")
                Spacer()
                Text("Click a control to edit it")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(16)
        .background(Color(nsColor: .controlBackgroundColor).opacity(0.55), in: RoundedRectangle(cornerRadius: 12))
        .overlay {
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.secondary.opacity(0.16))
        }
    }

    @ViewBuilder
    private func bodies(in size: CGSize) -> some View {
        JoyConBodyShape(side: .left)
            .fill(Color(red: 0.25, green: 0.76, blue: 0.91).gradient)
            .overlay {
                JoyConBodyShape(side: .left)
                    .stroke(Color.black.opacity(0.22), lineWidth: 1)
            }
            .frame(width: size.width * 0.34, height: size.height * 0.82)
            .position(x: size.width * 0.25, y: size.height * 0.55)

        JoyConBodyShape(side: .right)
            .fill(Color(red: 0.98, green: 0.34, blue: 0.38).gradient)
            .overlay {
                JoyConBodyShape(side: .right)
                    .stroke(Color.black.opacity(0.22), lineWidth: 1)
            }
            .frame(width: size.width * 0.34, height: size.height * 0.82)
            .position(x: size.width * 0.75, y: size.height * 0.55)

        RoundedRectangle(cornerRadius: 4)
            .fill(Color.black.opacity(0.64))
            .frame(width: size.width * 0.027, height: size.height * 0.69)
            .position(x: size.width * 0.414, y: size.height * 0.54)

        RoundedRectangle(cornerRadius: 4)
            .fill(Color.black.opacity(0.64))
            .frame(width: size.width * 0.027, height: size.height * 0.69)
            .position(x: size.width * 0.586, y: size.height * 0.54)
    }

    @ViewBuilder
    private func shoulderButtons(in size: CGSize) -> some View {
        control("ZL", input: .leftTrigger, width: 46, height: 22, at: .init(x: 0.16, y: 0.08), in: size)
        control("L", input: .leftShoulder, width: 42, height: 22, at: .init(x: 0.33, y: 0.08), in: size)
        control("R", input: .rightShoulder, width: 42, height: 22, at: .init(x: 0.67, y: 0.08), in: size)
        control("ZR", input: .rightTrigger, width: 46, height: 22, at: .init(x: 0.84, y: 0.08), in: size)
    }

    @ViewBuilder
    private func leftControls(in size: CGSize) -> some View {
        control("−", input: .buttonMinus, width: 34, height: 20, at: .init(x: 0.34, y: 0.20), in: size)

        JoyConStickView(
            pressInput: .leftStickPress,
            upInput: .leftStickUp,
            downInput: .leftStickDown,
            leftInput: .leftStickLeft,
            rightInput: .leftStickRight,
            selectedInput: selectedInput,
            activeInput: activeInput,
            onSelect: onSelect
        )
        .frame(width: 72, height: 72)
        .position(x: size.width * 0.25, y: size.height * 0.33)

        control("▲", input: .dpadUp, at: .init(x: 0.25, y: 0.54), in: size)
        control("▼", input: .dpadDown, at: .init(x: 0.25, y: 0.68), in: size)
        control("◀", input: .dpadLeft, at: .init(x: 0.18, y: 0.61), in: size)
        control("▶", input: .dpadRight, at: .init(x: 0.32, y: 0.61), in: size)

        control("▣", input: .buttonCapture, width: 30, height: 30, at: .init(x: 0.34, y: 0.82), in: size)
    }

    @ViewBuilder
    private func rightControls(in size: CGSize) -> some View {
        control("+", input: .buttonPlus, width: 34, height: 20, at: .init(x: 0.66, y: 0.20), in: size)

        control("X", input: .buttonX, at: .init(x: 0.75, y: 0.26), in: size)
        control("B", input: .buttonB, at: .init(x: 0.75, y: 0.40), in: size)
        control("Y", input: .buttonY, at: .init(x: 0.68, y: 0.33), in: size)
        control("A", input: .buttonA, at: .init(x: 0.82, y: 0.33), in: size)

        JoyConStickView(
            pressInput: .rightStickPress,
            upInput: .rightStickUp,
            downInput: .rightStickDown,
            leftInput: .rightStickLeft,
            rightInput: .rightStickRight,
            selectedInput: selectedInput,
            activeInput: activeInput,
            onSelect: onSelect
        )
        .frame(width: 72, height: 72)
        .position(x: size.width * 0.75, y: size.height * 0.61)

        control("⌂", input: .buttonHome, width: 30, height: 30, at: .init(x: 0.66, y: 0.82), in: size)
    }

    @ViewBuilder
    private func railButtons(in size: CGSize) -> some View {
        control("SL", input: .buttonSL, width: 34, height: 18, at: .init(x: 0.43, y: 0.44), in: size)
        control("SR", input: .buttonSR, width: 34, height: 18, at: .init(x: 0.43, y: 0.62), in: size)
        control("SL", input: .buttonSL, width: 34, height: 18, at: .init(x: 0.57, y: 0.44), in: size)
        control("SR", input: .buttonSR, width: 34, height: 18, at: .init(x: 0.57, y: 0.62), in: size)
    }

    private func control(
        _ label: String,
        input: ControllerInput,
        width: CGFloat = 30,
        height: CGFloat = 30,
        at point: CGPoint,
        in size: CGSize
    ) -> some View {
        Button {
            onSelect(input)
        } label: {
            JoyConControl(
                label: label,
                width: width,
                height: height,
                isSelected: selectedInput == input,
                isActive: activeInput == input
            )
        }
        .buttonStyle(.plain)
        .help(input.displayName)
        .accessibilityLabel(input.displayName)
        .position(x: size.width * point.x, y: size.height * point.y)
    }

    private func legend(color: Color, text: String) -> some View {
        HStack(spacing: 6) {
            Circle()
                .fill(color)
                .frame(width: 7, height: 7)
            Text(text)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}

private enum DiagramSide {
    case left
    case right
}

private struct JoyConBodyShape: Shape {
    let side: DiagramSide

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let upperRadius = rect.width * 0.28
        let lowerRadius = rect.width * 0.36

        switch side {
        case .left:
            path.move(to: CGPoint(x: rect.maxX, y: rect.minY))
            path.addLine(to: CGPoint(x: rect.minX + upperRadius, y: rect.minY))
            path.addQuadCurve(
                to: CGPoint(x: rect.minX, y: rect.minY + upperRadius),
                control: CGPoint(x: rect.minX, y: rect.minY)
            )
            path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY - lowerRadius))
            path.addQuadCurve(
                to: CGPoint(x: rect.minX + lowerRadius, y: rect.maxY),
                control: CGPoint(x: rect.minX, y: rect.maxY)
            )
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        case .right:
            path.move(to: CGPoint(x: rect.minX, y: rect.minY))
            path.addLine(to: CGPoint(x: rect.maxX - upperRadius, y: rect.minY))
            path.addQuadCurve(
                to: CGPoint(x: rect.maxX, y: rect.minY + upperRadius),
                control: CGPoint(x: rect.maxX, y: rect.minY)
            )
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY - lowerRadius))
            path.addQuadCurve(
                to: CGPoint(x: rect.maxX - lowerRadius, y: rect.maxY),
                control: CGPoint(x: rect.maxX, y: rect.maxY)
            )
            path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        }

        path.closeSubpath()
        return path
    }
}

private struct JoyConControl: View {
    let label: String
    let width: CGFloat
    let height: CGFloat
    let isSelected: Bool
    let isActive: Bool

    private var highlightColor: Color {
        if isActive { return .green }
        if isSelected { return .yellow }
        return .clear
    }

    var body: some View {
        Text(label)
            .font(.system(size: min(width, height) * 0.43, weight: .bold, design: .rounded))
            .foregroundStyle(.white)
            .frame(width: width, height: height)
            .background(Color.black.opacity(0.76), in: RoundedRectangle(cornerRadius: height / 2))
            .overlay {
                RoundedRectangle(cornerRadius: height / 2)
                    .stroke(Color.white.opacity(0.18), lineWidth: 1)
            }
            .overlay {
                RoundedRectangle(cornerRadius: height / 2)
                    .stroke(highlightColor, lineWidth: isActive ? 4 : 3)
                    .padding(-4)
            }
            .scaleEffect(isActive ? 1.16 : (isSelected ? 1.10 : 1))
            .shadow(color: highlightColor.opacity(0.75), radius: isActive || isSelected ? 8 : 0)
    }
}

private struct JoyConStickView: View {
    let pressInput: ControllerInput
    let upInput: ControllerInput
    let downInput: ControllerInput
    let leftInput: ControllerInput
    let rightInput: ControllerInput
    let selectedInput: ControllerInput?
    let activeInput: ControllerInput?
    let onSelect: (ControllerInput) -> Void

    var body: some View {
        ZStack {
            Circle()
                .fill(Color.black.opacity(0.80))
                .overlay {
                    Circle().stroke(Color.white.opacity(0.20), lineWidth: 1)
                }

            Button {
                onSelect(pressInput)
            } label: {
                Circle()
                    .fill(Color(white: 0.25))
                    .overlay {
                        Circle().stroke(highlight(for: pressInput), lineWidth: 3)
                    }
                    .shadow(color: highlight(for: pressInput).opacity(0.75), radius: isHighlighted(pressInput) ? 7 : 0)
                    .frame(width: 38, height: 38)
            }
            .buttonStyle(.plain)
            .help(pressInput.displayName)
            .accessibilityLabel(pressInput.displayName)

            directionButton("▲", input: upInput, x: 0, y: -27)
            directionButton("▼", input: downInput, x: 0, y: 27)
            directionButton("◀", input: leftInput, x: -27, y: 0)
            directionButton("▶", input: rightInput, x: 27, y: 0)
        }
    }

    private func directionButton(_ label: String, input: ControllerInput, x: CGFloat, y: CGFloat) -> some View {
        Button {
            onSelect(input)
        } label: {
            Text(label)
                .font(.system(size: 9, weight: .bold))
                .foregroundStyle(isHighlighted(input) ? highlight(for: input) : Color.white.opacity(0.58))
                .scaleEffect(isHighlighted(input) ? 1.45 : 1)
                .shadow(color: highlight(for: input).opacity(0.8), radius: isHighlighted(input) ? 5 : 0)
                .frame(width: 18, height: 18)
        }
        .buttonStyle(.plain)
        .help(input.displayName)
        .accessibilityLabel(input.displayName)
        .offset(x: x, y: y)
    }

    private func isHighlighted(_ input: ControllerInput) -> Bool {
        selectedInput == input || activeInput == input
    }

    private func highlight(for input: ControllerInput) -> Color {
        if activeInput == input { return .green }
        if selectedInput == input { return .yellow }
        return .clear
    }
}
