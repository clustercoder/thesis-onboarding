import SwiftUI

struct OnboardingContainerView: View {
    @EnvironmentObject var viewModel: OnboardingViewModel
    let step: OnboardingStepID

    private var transition: AnyTransition {
        let forward = AnyTransition.asymmetric(
            insertion: .move(edge: .trailing).combined(with: .opacity),
            removal: .move(edge: .leading).combined(with: .opacity)
        )
        let backward = AnyTransition.asymmetric(
            insertion: .move(edge: .leading).combined(with: .opacity),
            removal: .move(edge: .trailing).combined(with: .opacity)
        )
        return viewModel.navigationDirection == .forward ? forward : backward
    }

    var body: some View {
        VStack(spacing: 0) {
            if step != .completion {
                header
                    .padding(.bottom, 44)
            }

            ZStack {
                stepView(for: step)
                    .id(step)
                    .transition(transition)
            }
            .animation(.easeOut(duration: Theme.Motion.stepTransition), value: step)
        }
        .padding(.horizontal, Theme.Spacing.screenHorizontal)
        .padding(.top, step == .completion ? 0 : 22)
        .padding(.bottom, 24)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(Theme.Color.background)
    }

    private var header: some View {
        HStack(spacing: 16) {
            Button(action: { viewModel.goBack() }) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 22, weight: .medium))
                    .foregroundStyle(viewModel.canGoBack ? Theme.Color.textSecondary : .clear)
                    .frame(width: 24, height: 24)
            }
            .disabled(!viewModel.canGoBack)

            ProgressBarView(progress: step.progress)
        }
    }

    @ViewBuilder
    private func stepView(for step: OnboardingStepID) -> some View {
        switch step {
        case .name: NameStepView()
        case .experience: ExperienceStepView()
        case .goals: GoalsStepView()
        case .horizon: HorizonStepView()
        case .volatility: VolatilityStepView()
        case .behavior: BehaviorStepView()
        case .infoNeeds: InfoNeedsStepView()
        case .focus: FocusStepView()
        case .portfolio: PortfolioStepView()
        case .summary: SummaryStepView()
        case .completion: CompletionView()
        }
    }
}
