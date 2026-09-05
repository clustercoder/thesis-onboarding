import SwiftUI

struct SummaryStepView: View {
    @EnvironmentObject var viewModel: OnboardingViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.questionToOptions) {
            Text("Here's how we'll shape Thesis for you.")
                .font(.system(size: 26, weight: .bold))
                .foregroundStyle(Theme.Color.textPrimary)
                .lineSpacing(6)

            Text(viewModel.summaryText)
                .font(.system(size: 16))
                .foregroundStyle(Theme.Color.textSecondary)
                .lineSpacing(6)

            VStack(alignment: .leading, spacing: 16) {
                Text("YOUR THESIS")
                    .font(.system(size: 12, weight: .bold))
                    .tracking(1)
                    .foregroundStyle(Theme.Color.textTertiary)

                VStack(spacing: 0) {
                    ForEach(Array(viewModel.profileRows.enumerated()), id: \.offset) { _, row in
                        HStack(alignment: .lastTextBaseline) {
                            Text(row.label)
                                .font(.system(size: 13))
                                .foregroundStyle(Theme.Color.textTertiaryAlt)
                            Spacer()
                            Text(row.value)
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundStyle(Theme.Color.textPrimary)
                                .multilineTextAlignment(.trailing)
                        }
                        .padding(.top, 12)
                        .overlay(alignment: .top) {
                            Rectangle().fill(Theme.Color.borderSubtle).frame(height: 1)
                        }
                    }
                }
            }
            .padding(22)
            .background(Theme.Color.surface)
            .overlay(
                RoundedRectangle(cornerRadius: 20).stroke(Theme.Color.borderCard, lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: 20))

            PillButton("Build my Thesis") {
                viewModel.buildThesis()
            }
        }
    }
}
