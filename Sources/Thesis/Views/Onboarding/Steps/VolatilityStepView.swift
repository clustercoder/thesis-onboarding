import SwiftUI

struct VolatilityStepView: View {
    @EnvironmentObject var viewModel: OnboardingViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.questionToOptions) {
            Text("When an investment moves against you, what usually feels right?")
                .font(Theme.Typography.question(28))
                .foregroundStyle(Theme.Color.textPrimary)
                .lineSpacing(4)

            VStack(spacing: Theme.Spacing.optionGap) {
                ForEach(OptionData.riskBehaviors, id: \.self) { option in
                    OptionCard(
                        label: option,
                        isSelected: viewModel.answers.volatilityBehavior == option,
                        showCheckmark: false
                    ) {
                        viewModel.selectVolatility(option)
                    }
                }
            }

            if let microcopy = viewModel.volatilityMicrocopy {
                Text(microcopy)
                    .font(.system(size: 14))
                    .foregroundStyle(Theme.Color.textSecondary)
                    .transition(.opacity)
            }
        }
    }
}
