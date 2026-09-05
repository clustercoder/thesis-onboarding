import Foundation

struct ExperienceOption {
    let value: ExperienceLevel
    let label: String
    let sub: String
    let microcopy: String
}

enum OptionData {
    static let experience: [ExperienceOption] = [
        ExperienceOption(
            value: .gettingStarted,
            label: "I'm just getting started",
            sub: "New to investing",
            microcopy: "Thesis will keep things clear while you learn the ropes."
        ),
        ExperienceOption(
            value: .basics,
            label: "I know the basics",
            sub: "Comfortable with core concepts",
            microcopy: "That's enough to start. Thesis can adapt to how deep you want to go."
        ),
        ExperienceOption(
            value: .active,
            label: "I actively follow markets",
            sub: "You track markets regularly",
            microcopy: "Thesis will match the pace you already keep."
        ),
        ExperienceOption(
            value: .professional,
            label: "I invest professionally",
            sub: "This is your profession or serious practice",
            microcopy: "Thesis will surface signal, not noise, at your level."
        )
    ]

    static let goals: [String] = [
        "Finding better opportunities",
        "Understanding what moves markets",
        "Building conviction",
        "Managing risk",
        "Staying informed",
        "Researching companies faster"
    ]

    static let horizons: [(value: TimeHorizon, label: String)] = [
        (.days, "Days to weeks"),
        (.months, "A few months"),
        (.oneToThree, "1–3 years"),
        (.threeToTen, "3–10 years"),
        (.tenPlus, "10+ years")
    ]

    static func horizonEducation(for horizon: TimeHorizon) -> String {
        switch horizon {
        case .days, .months:
            "Short horizons can move quickly. Context matters even more."
        case .oneToThree:
            "A few years gives a thesis room to develop."
        case .threeToTen, .tenPlus:
            "Long horizons give a thesis more time to play out."
        }
    }

    static let riskBehaviors: [String] = [
        "I want to understand what changed before acting",
        "I usually hold through volatility",
        "I tend to reduce risk quickly",
        "It depends on the thesis"
    ]

    static let volatilityMicrocopy = "That's useful. Thesis will use this to shape how signals are presented."

    static let currentBehavior: [String] = [
        "I follow the news",
        "I research companies myself",
        "I follow analysts",
        "I follow communities / social media",
        "I mostly use instinct",
        "A combination of these"
    ]

    static let infoNeeds: [String] = [
        "What changed today",
        "Why the market moved",
        "Where conviction is building",
        "Contradictory signals",
        "Company-specific news",
        "Bigger market themes"
    ]

    static let focusAreas: [String] = [
        "Building long-term wealth",
        "Finding my next big idea",
        "Becoming a better investor",
        "Staying ahead of the news",
        "Understanding companies I already own",
        "Building conviction before I act"
    ]

    static let tickers: [String] = ["TSLA", "NVDA", "AAPL", "GOOGL", "AMZN", "MSFT"]
}
