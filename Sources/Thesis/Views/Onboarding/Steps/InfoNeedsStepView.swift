import SwiftUI

struct InfoNeedsStepView: View {
    @EnvironmentObject var viewModel: OnboardingViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.questionToOptions) {
            Text("What do you want Thesis to cut through for you?")
                .font(Theme.Typography.question(28))
                .foregroundStyle(Theme.Color.textPrimary)
                .lineSpacing(4)

            Text("Select all that apply")
                .font(.system(size: 13))
                .foregroundStyle(Theme.Color.textMuted)

            VStack(spacing: 10) {
                ForEach(OptionData.infoNeeds, id: \.self) { option in
                    OptionCard(
                        label: option,
                        isSelected: viewModel.answers.infoNeeds.contains(option)
                    ) {
                        viewModel.toggleInfoNeed(option)
                    }
                }
            }

            PillButton("Continue", isEnabled: !viewModel.answers.infoNeeds.isEmpty) {
                viewModel.continueFromInfoNeeds()
            }
        }
    }
}
