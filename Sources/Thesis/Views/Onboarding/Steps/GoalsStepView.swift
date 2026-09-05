import SwiftUI

struct GoalsStepView: View {
    @EnvironmentObject var viewModel: OnboardingViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.questionToOptions) {
            Text("What are you trying to get better at?")
                .font(Theme.Typography.question(28))
                .foregroundStyle(Theme.Color.textPrimary)
                .lineSpacing(4)

            Text("Select all that apply")
                .font(.system(size: 13))
                .foregroundStyle(Theme.Color.textMuted)

            VStack(spacing: 10) {
                ForEach(OptionData.goals, id: \.self) { goal in
                    OptionCard(
                        label: goal,
                        isSelected: viewModel.answers.goals.contains(goal)
                    ) {
                        viewModel.toggleGoal(goal)
                    }
                }
            }

            PillButton("Continue", isEnabled: !viewModel.answers.goals.isEmpty) {
                viewModel.continueFromGoals()
            }
        }
    }
}
