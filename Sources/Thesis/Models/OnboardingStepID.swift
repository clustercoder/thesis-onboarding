import Foundation

enum OnboardingStepID: String, Codable, CaseIterable {
    case name = "onb1"
    case experience = "onb2"
    case goals = "onb3"
    case horizon = "onb4"
    case volatility = "onb5"
    case behavior = "onb6"
    case infoNeeds = "onb7"
    case focus = "onb8"
    case portfolio = "onb9"
    case summary = "onb10"
    case completion = "onb11"

    static let flowOrder: [OnboardingStepID] = [
        .name, .experience, .goals, .horizon, .volatility,
        .behavior, .infoNeeds, .focus, .portfolio, .summary
    ]

    var next: OnboardingStepID? {
        guard let index = Self.flowOrder.firstIndex(of: self) else { return nil }
        let nextIndex = index + 1
        if nextIndex < Self.flowOrder.count { return Self.flowOrder[nextIndex] }
        if self == .summary { return .completion }
        return nil
    }

    /// Progress bar fill, 0...1. Completion always reads as full.
    var progress: Double {
        if self == .completion { return 1.0 }
        guard let index = Self.flowOrder.firstIndex(of: self) else { return 0 }
        return Double(index + 1) / Double(Self.flowOrder.count)
    }
}
