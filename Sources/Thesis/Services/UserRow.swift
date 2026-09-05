import Foundation

/// Mirrors the `public.users` table (see supabase/schema.sql) for PostgREST requests.
struct UserRow: Codable, Equatable {
    let id: String
    let authProvider: AuthProvider
    let firstName: String
    let onboardingComplete: Bool
    let answers: OnboardingAnswers

    enum CodingKeys: String, CodingKey {
        case id
        case authProvider = "auth_provider"
        case firstName = "first_name"
        case onboardingComplete = "onboarding_complete"
        case answers
    }

    init(state: OnboardingState) {
        self.id = state.user?.id ?? ""
        self.authProvider = state.user?.authProvider ?? .google
        self.firstName = state.answers.firstName
        self.onboardingComplete = state.onboardingComplete
        self.answers = state.answers
    }
}
