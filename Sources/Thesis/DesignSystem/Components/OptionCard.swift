import SwiftUI

struct OptionCard: View {
    let label: String
    var sub: String?
    let isSelected: Bool
    let showCheckmark: Bool
    let action: () -> Void

    init(
        label: String,
        sub: String? = nil,
        isSelected: Bool,
        showCheckmark: Bool = true,
        action: @escaping () -> Void
    ) {
        self.label = label
        self.sub = sub
        self.isSelected = isSelected
        self.showCheckmark = showCheckmark
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 3) {
                    Text(label)
                        .font(Theme.Typography.optionLabel)
                        .foregroundStyle(Theme.Color.textPrimary)
                        .multilineTextAlignment(.leading)
                    if let sub {
                        Text(sub)
                            .font(Theme.Typography.optionSub)
                            .foregroundStyle(Theme.Color.textTertiaryAlt)
                            .multilineTextAlignment(.leading)
                    }
                }
                Spacer(minLength: 8)
                if showCheckmark && isSelected {
                    Image(systemName: "checkmark")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(Theme.Color.textPrimary)
                }
            }
            .padding(Theme.Spacing.optionInternalPadding)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(isSelected ? Theme.Color.surfaceElevated : Theme.Color.surface)
            .overlay(
                RoundedRectangle(cornerRadius: Theme.Radius.card)
                    .stroke(isSelected ? Theme.Color.textPrimary : Theme.Color.borderCard, lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.card))
        }
        .buttonStyle(.plain)
        .frame(minHeight: 44)
        .animation(.easeOut(duration: Theme.Motion.selectFeedback), value: isSelected)
    }
}
