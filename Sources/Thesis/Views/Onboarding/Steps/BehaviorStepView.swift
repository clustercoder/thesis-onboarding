import SwiftUI

struct BehaviorStepView: View {
    @EnvironmentObject var viewModel: OnboardingViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.questionToOptions) {
            Text("How do you currently decide what to invest in?")
                .font(Theme.Typography.question(28))
                .foregroundStyle(Theme.Color.textPrimary)
                .lineSpacing(4)

            Text("Select all that apply")
                .font(.system(size: 13))
                .foregroundStyle(Theme.Color.textMuted)

            VStack(spacing: 10) {
                ForEach(OptionData.currentBehavior, id: \.self) { option in
                    OptionCard(
                        label: option,
                        isSelected: viewModel.answers.behavior.contains(option)
                    ) {
                        viewModel.toggleBehavior(option)
                    }
                }
            }

            PillButton("Continue", isEnabled: !viewModel.answers.behavior.isEmpty) {
                viewModel.continueFromBehavior()
            }
        }
    }
}
