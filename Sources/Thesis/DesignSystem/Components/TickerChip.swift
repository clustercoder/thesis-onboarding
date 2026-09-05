import SwiftUI

struct TickerChip: View {
    let label: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(label)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(Theme.Color.textPrimary)
                .padding(.horizontal, 18)
                .padding(.vertical, 10)
                .background(isSelected ? Theme.Color.surfaceElevated : Theme.Color.surface)
                .overlay(
                    Capsule().stroke(isSelected ? Theme.Color.textPrimary : Theme.Color.borderCard, lineWidth: 1)
                )
                .clipShape(Capsule())
        }
        .buttonStyle(.plain)
        .animation(.easeOut(duration: Theme.Motion.selectFeedback), value: isSelected)
    }
}
