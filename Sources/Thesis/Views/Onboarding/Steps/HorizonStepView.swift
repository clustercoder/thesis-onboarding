import SwiftUI

struct HorizonStepView: View {
    @EnvironmentObject var viewModel: OnboardingViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.questionToOptions) {
            Text("When you invest, how far ahead are you usually thinking?")
                .font(Theme.Typography.question(28))
                .foregroundStyle(Theme.Color.textPrimary)
                .lineSpacing(4)

            VStack(spacing: Theme.Spacing.optionGap) {
                ForEach(OptionData.horizons, id: \.value) { option in
                    OptionCard(
                        label: option.label,
                        isSelected: viewModel.answers.horizon == option.value,
                        showCheckmark: false
                    ) {
                        viewModel.selectHorizon(option.value)
                    }
                }
            }

            if let line = viewModel.horizonEducationLine {
                Text(line)
                    .font(.system(size: 14))
                    .foregroundStyle(Theme.Color.textSecondary)
                    .transition(.opacity)
            }
        }
    }
}
