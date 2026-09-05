import SwiftUI

struct AuthView: View {
    @EnvironmentObject var viewModel: OnboardingViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("THESIS")
                .font(Theme.Typography.eyebrow)
                .tracking(1.5)
                .foregroundStyle(Theme.Color.textTertiary)
                .padding(.top, 8)

            Spacer()

            VStack(alignment: .leading, spacing: 16) {
                Text("Invest with a thesis.")
                    .font(Theme.Typography.authHeadline)
                    .tracking(-0.3)
                    .foregroundStyle(Theme.Color.textPrimary)
                    .lineSpacing(4)

                Text("Build a market view that's tailored to how you think, what you watch, and where you're going.")
                    .font(Theme.Typography.supportingCopy)
                    .foregroundStyle(Theme.Color.textSecondary)
                    .lineSpacing(6)
                    .frame(maxWidth: 340, alignment: .leading)
            }

            Spacer()

            VStack(spacing: 12) {
                AuthProviderButton(
                    label: viewModel.isAuthenticating ? "Connecting…" : "Continue with Google",
                    isDisabled: viewModel.isAuthenticating,
                    background: SwiftUI.Color(hex: "0C0C0C"),
                    glyph: { GoogleGlyph() }
                ) {
                    Task { await viewModel.signIn(provider: .google) }
                }

                AuthProviderButton(
                    label: viewModel.isAuthenticating ? "Connecting…" : "Continue with Apple",
                    isDisabled: viewModel.isAuthenticating,
                    background: .clear,
                    glyph: {
                        Image(systemName: "apple.logo")
                            .font(.system(size: 18))
                            .foregroundStyle(Theme.Color.textPrimary)
                    }
                ) {
                    Task { await viewModel.signIn(provider: .apple) }
                }

                if let authError = viewModel.authError {
                    Text(authError)
                        .font(.system(size: 13))
                        .foregroundStyle(Theme.Color.negative)
                        .multilineTextAlignment(.center)
                        .padding(.top, 4)
                }

                Text("By continuing you agree to Thesis's Terms and Privacy Policy.")
                    .font(.system(size: 11))
                    .foregroundStyle(Theme.Color.textMuted)
                    .multilineTextAlignment(.center)
                    .lineSpacing(3)
                    .padding(.top, 10)
                    .frame(maxWidth: .infinity)
            }
        }
        .padding(.horizontal, Theme.Spacing.screenHorizontal)
        .padding(.top, 24)
        .padding(.bottom, 24)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(Theme.Color.background)
    }
}

private struct AuthProviderButton<Glyph: View>: View {
    let label: String
    let isDisabled: Bool
    let background: Color
    @ViewBuilder let glyph: () -> Glyph
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 10) {
                glyph().frame(width: 18, height: 18)
                Text(label)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(Theme.Color.textPrimary)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 54)
            .background(background)
            .overlay(
                Capsule().stroke(Theme.Color.borderButton, lineWidth: 1)
            )
            .clipShape(Capsule())
        }
        .buttonStyle(.plain)
        .disabled(isDisabled)
        .opacity(isDisabled ? 0.85 : 1)
    }
}

private struct GoogleGlyph: View {
    var body: some View {
        Circle()
            .fill(
                AngularGradient(
                    gradient: Gradient(colors: [
                        SwiftUI.Color(hex: "EA4335"),
                        SwiftUI.Color(hex: "4285F4"),
                        SwiftUI.Color(hex: "34A853"),
                        SwiftUI.Color(hex: "FBBC05"),
                        SwiftUI.Color(hex: "EA4335")
                    ]),
                    center: .center,
                    angle: .degrees(-45)
                )
            )
    }
}

#Preview {
    AuthView().environmentObject(OnboardingViewModel())
}
