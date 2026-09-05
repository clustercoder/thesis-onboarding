import SwiftUI

struct ExperienceStepView: View {
    @EnvironmentObject var viewModel: OnboardingViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.questionToOptions) {
            Text("How would you describe your experience in the markets?")
                .font(Theme.Typography.question(28))
                .foregroundStyle(Theme.Color.textPrimary)
                .lineSpacing(4)

            VStack(spacing: Theme.Spacing.optionGap) {
                ForEach(OptionData.experience, id: \.value) { option in
                    OptionCard(
                        label: option.label,
                        sub: option.sub,
                        isSelected: viewModel.answers.experience == option.value
                    ) {
                        viewModel.selectExperience(option.value)
                    }
                }
            }

            if let microcopy = viewModel.experienceMicrocopy {
                Text(microcopy)
                    .font(.system(size: 14))
                    .foregroundStyle(Theme.Color.textSecondary)
                    .transition(.opacity)
            }
        }
    }
}
