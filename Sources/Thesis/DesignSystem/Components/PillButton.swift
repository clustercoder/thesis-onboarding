import SwiftUI

struct PillButton: View {
    let title: String
    let isEnabled: Bool
    let height: CGFloat
    let action: () -> Void

    init(_ title: String, isEnabled: Bool = true, height: CGFloat = 56, action: @escaping () -> Void) {
        self.title = title
        self.isEnabled = isEnabled
        self.height = height
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(Theme.Typography.buttonLabel)
                .foregroundStyle(isEnabled ? Theme.Color.ctaText : Theme.Color.textMuted)
                .frame(maxWidth: .infinity)
                .frame(height: height)
                .background(isEnabled ? Theme.Color.ctaFill : Theme.Color.ctaDisabledFill)
                .clipShape(Capsule())
        }
        .disabled(!isEnabled)
        .animation(.easeOut(duration: Theme.Motion.selectFeedback), value: isEnabled)
    }
}

struct OutlinePillButton: View {
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(Theme.Color.textPrimary)
                .frame(maxWidth: .infinity)
                .frame(height: 54)
                .background(Theme.Color.surface)
                .overlay(
                    Capsule().stroke(Theme.Color.borderButton, lineWidth: 1)
                )
                .clipShape(Capsule())
        }
    }
}
