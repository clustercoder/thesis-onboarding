import SwiftUI

struct RootRouterView: View {
    @EnvironmentObject var viewModel: OnboardingViewModel
    @State private var hasBootstrapped = false

    var body: some View {
        Group {
            switch viewModel.phase {
            case .authRequired, .authenticating:
                AuthView()
            case .onboarding(let step):
                OnboardingContainerView(step: step)
            case .appReady:
                HomeShellView()
            }
        }
        .task {
            guard !hasBootstrapped else { return }
            hasBootstrapped = true
            await viewModel.bootstrap()
        }
    }
}
