import Foundation

struct OnboardingState: Codable, Equatable {
    var user: UserAccount?
    var answers: OnboardingAnswers = OnboardingAnswers()
    var currentStep: OnboardingStepID = .name
    var onboardingComplete: Bool = false
}
