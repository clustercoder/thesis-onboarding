import SwiftUI

struct NameStepView: View {
    @EnvironmentObject var viewModel: OnboardingViewModel
    @FocusState private var isFocused: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.questionToOptions) {
            Text("What should we call you?")
                .font(Theme.Typography.question())
                .foregroundStyle(Theme.Color.textPrimary)
                .lineSpacing(4)

            TextField(
                "",
                text: $viewModel.answers.firstName,
                prompt: Text("First name").foregroundStyle(Theme.Color.textMuted)
            )
            .focused($isFocused)
            .font(.system(size: 18))
            .foregroundStyle(Theme.Color.textPrimary)
            .padding(.horizontal, 20)
            .frame(height: 56)
            .background(Theme.Color.surface)
            .overlay(
                RoundedRectangle(cornerRadius: Theme.Radius.field)
                    .stroke(Theme.Color.borderButton, lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.field))
            .submitLabel(.continue)
            .onSubmit { viewModel.submitName() }
            .onChange(of: viewModel.answers.firstName) {
                viewModel.nameSubmitted = false
            }

            if viewModel.nameSubmitted {
                Text("Good to meet you, \(viewModel.answers.firstName).")
                    .font(.system(size: 15))
                    .foregroundStyle(Theme.Color.textSecondary)
                    .transition(.opacity)
            }

            PillButton(
                "Continue",
                isEnabled: !viewModel.answers.firstName.trimmingCharacters(in: .whitespaces).isEmpty
            ) {
                viewModel.submitName()
            }
        }
        .onAppear { isFocused = true }
    }
}
