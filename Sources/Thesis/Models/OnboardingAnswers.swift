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
}
