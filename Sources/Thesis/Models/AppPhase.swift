import Foundation

enum AppPhase: Equatable {
    case authRequired
    case onboarding(OnboardingStepID)
    case appReady

    /// Startup routing rule from the handoff spec:
    /// no local session -> AUTH_REQUIRED; a session with incomplete onboarding -> resume at
    /// the saved step; a session with onboarding already complete -> APP_READY, skipping
    /// Auth and Onboarding entirely (the returning-user bypass).
    static func resolve(localUserId: String?, cachedState: OnboardingState?) -> AppPhase {
        guard localUserId != nil else { return .authRequired }
        guard let state = cachedState else { return .onboarding(.name) }
        if state.onboardingComplete { return .appReady }
        return .onboarding(state.currentStep)
    }
}
