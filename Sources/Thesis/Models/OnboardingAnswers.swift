import Foundation

enum ExperienceLevel: String, Codable, CaseIterable {
    case gettingStarted = "getting_started"
    case basics
    case active
    case professional
}

enum TimeHorizon: String, Codable, CaseIterable {
    case days
    case months
    case oneToThree = "1-3y"
    case threeToTen = "3-10y"
    case tenPlus = "10y+"
}

struct OnboardingAnswers: Codable, Equatable {
    var firstName: String = ""
    var experience: ExperienceLevel?
    var goals: [String] = []
    var horizon: TimeHorizon?
    var volatilityBehavior: String?
    var behavior: [String] = []
    var infoNeeds: [String] = []
    var focus: String?
    var portfolioInterest: Bool?
    var watchlist: [String] = []

    enum CodingKeys: String, CodingKey {
        case firstName, experience, goals, horizon, volatilityBehavior, behavior, infoNeeds, focus,
             portfolioInterest, watchlist
    }

    init() {}

    /// Custom decoding so a partial `answers` payload — e.g. the `{}` a freshly created row starts
    /// with before any onboarding step is answered, or an older row missing a since-added field —
    /// still decodes instead of throwing. Swift's synthesized `Decodable` requires every key to be
    /// present even when the property declares a default value; defaults only apply to the
    /// memberwise initializer, not to decoding.
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        firstName = try container.decodeIfPresent(String.self, forKey: .firstName) ?? ""
        experience = try container.decodeIfPresent(ExperienceLevel.self, forKey: .experience)
        goals = try container.decodeIfPresent([String].self, forKey: .goals) ?? []
        horizon = try container.decodeIfPresent(TimeHorizon.self, forKey: .horizon)
        volatilityBehavior = try container.decodeIfPresent(String.self, forKey: .volatilityBehavior)
        behavior = try container.decodeIfPresent([String].self, forKey: .behavior) ?? []
        infoNeeds = try container.decodeIfPresent([String].self, forKey: .infoNeeds) ?? []
        focus = try container.decodeIfPresent(String.self, forKey: .focus)
        portfolioInterest = try container.decodeIfPresent(Bool.self, forKey: .portfolioInterest)
        watchlist = try container.decodeIfPresent([String].self, forKey: .watchlist) ?? []
    }
}
