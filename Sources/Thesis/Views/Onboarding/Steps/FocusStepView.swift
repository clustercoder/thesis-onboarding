import SwiftUI

struct FocusStepView: View {
    @EnvironmentObject var viewModel: OnboardingViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.questionToOptions) {
            Text("What do you care about most right now?")
                .font(Theme.Typography.question(28))
                .foregroundStyle(Theme.Color.textPrimary)
                .lineSpacing(4)

            VStack(spacing: Theme.Spacing.optionGap) {
                ForEach(OptionData.focusAreas, id: \.self) { option in
                    OptionCard(
                        label: option,
                        isSelected: viewModel.answers.focus == option,
                        showCheckmark: false
                    ) {
                        viewModel.selectFocus(option)
                    }
                }
            }
        }
    }
}
