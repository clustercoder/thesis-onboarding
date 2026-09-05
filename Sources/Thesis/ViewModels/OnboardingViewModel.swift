import Foundation

enum NavigationDirection {
    case forward
    case backward
}

@MainActor
final class OnboardingViewModel: ObservableObject {
    @Published private(set) var phase: AppPhase = .authRequired
    @Published var answers = OnboardingAnswers()
    @Published private(set) var user: UserAccount?
    @Published private(set) var history: [OnboardingStepID] = []
    @Published private(set) var navigationDirection: NavigationDirection = .forward
    @Published var authError: String?
    @Published private(set) var isAuthenticating = false
    @Published var nameSubmitted = false
    @Published private(set) var isCompletionTransitioning = false
    @Published private(set) var onboardingComplete = false

    private let authService: AuthServicing
    private let persistence: PersistenceService
    private let supabase: SupabaseServicing

    init(
        authService: AuthServicing = AuthService(),
        persistence: PersistenceService = PersistenceService(),
        supabase: SupabaseServicing = SupabaseService()
    ) {
        self.authService = authService
        self.persistence = persistence
        self.supabase = supabase
    }

    var currentStep: OnboardingStepID? {
        if case let .onboarding(step) = phase { return step }
        return nil
    }

    var canGoBack: Bool { !history.isEmpty }

    // MARK: - Startup

    func bootstrap() async {
        let localId = persistence.localUserId
        let cached = persistence.loadState()
        phase = AppPhase.resolve(localUserId: localId, cachedState: cached)

        if let cached {
            user = cached.user
            answers = cached.answers
            onboardingComplete = cached.onboardingComplete
            nameSubmitted = !cached.answers.firstName.isEmpty
        }

        guard let localId else { return }
        if let remote = try? await supabase.fetchUser(id: localId) {
            answers = remote.answers
            onboardingComplete = remote.onboardingComplete
            if onboardingComplete {
                phase = .appReady
            }
        }
    }

    // MARK: - Auth

    func signIn(provider: AuthProvider) async {
        guard !isAuthenticating else { return }
        isAuthenticating = true
        authError = nil

        do {
            let signedIn = try await authService.signIn(provider: provider)
            let localId = persistence.createLocalUserId()
            user = UserAccount(id: localId, firstName: signedIn.firstName, authProvider: provider)
            answers = OnboardingAnswers()
            onboardingComplete = false
            history = []
            nameSubmitted = false
            isAuthenticating = false
            goTo(.name)
        } catch {
            isAuthenticating = false
            authError = AuthError.simulatedFailure.userFacingMessage
        }
    }

    func signOut() {
        persistence.clear()
        user = nil
        answers = OnboardingAnswers()
        onboardingComplete = false
        history = []
        nameSubmitted = false
        authError = nil
        isCompletionTransitioning = false
        phase = .authRequired
    }

    // MARK: - ONB-01 Name

    func submitName() {
        guard !answers.firstName.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        nameSubmitted = true
        persist()
        Task {
            try? await Task.sleep(nanoseconds: 550_000_000)
            guard currentStep == .name else { return }
            goTo(.experience)
        }
    }

    // MARK: - ONB-02 Experience (single-select, auto-advance)

    func selectExperience(_ value: ExperienceLevel) {
        answers.experience = value
        persist()
        Task {
            try? await Task.sleep(nanoseconds: 550_000_000)
            guard currentStep == .experience else { return }
            goTo(.goals)
        }
    }

    var experienceMicrocopy: String? {
        guard let value = answers.experience else { return nil }
        return OptionData.experience.first { $0.value == value }?.microcopy
    }

    // MARK: - ONB-03 Goals (multi-select, explicit continue)

    func toggleGoal(_ value: String) {
        toggle(value, in: &answers.goals)
        persist()
    }

    func continueFromGoals() {
        guard !answers.goals.isEmpty else { return }
        goTo(.horizon)
    }

    // MARK: - ONB-04 Horizon (single-select, hold to read, then auto-advance)

    func selectHorizon(_ value: TimeHorizon) {
        answers.horizon = value
        persist()
        Task {
            try? await Task.sleep(nanoseconds: 1_200_000_000)
            guard currentStep == .horizon else { return }
            goTo(.volatility)
        }
    }

    var horizonEducationLine: String? {
        guard let value = answers.horizon else { return nil }
        return OptionData.horizonEducation(for: value)
    }

    // MARK: - ONB-05 Volatility behavior (single-select, auto-advance)

    func selectVolatility(_ value: String) {
        answers.volatilityBehavior = value
        persist()
        Task {
            try? await Task.sleep(nanoseconds: 650_000_000)
            guard currentStep == .volatility else { return }
            goTo(.behavior)
        }
    }

    var volatilityMicrocopy: String? {
        answers.volatilityBehavior == nil ? nil : OptionData.volatilityMicrocopy
    }

    // MARK: - ONB-06 Current behavior (multi-select, explicit continue)

    func toggleBehavior(_ value: String) {
        toggle(value, in: &answers.behavior)
        persist()
    }

    func continueFromBehavior() {
        guard !answers.behavior.isEmpty else { return }
        goTo(.infoNeeds)
    }

    // MARK: - ONB-07 Info needs (multi-select, explicit continue)

    func toggleInfoNeed(_ value: String) {
        toggle(value, in: &answers.infoNeeds)
        persist()
    }

    func continueFromInfoNeeds() {
        guard !answers.infoNeeds.isEmpty else { return }
        goTo(.focus)
    }

    // MARK: - ONB-08 Focus (single-select, auto-advance)

    func selectFocus(_ value: String) {
        answers.focus = value
        persist()
        Task {
            try? await Task.sleep(nanoseconds: 450_000_000)
            guard currentStep == .focus else { return }
            goTo(.portfolio)
        }
    }

    // MARK: - ONB-09 Portfolio connection (conditional)

    func selectPortfolio(interested: Bool) {
        answers.portfolioInterest = interested
        if !interested { answers.watchlist = [] }
        persist()
    }

    func toggleWatchlistTicker(_ value: String) {
        toggle(value, in: &answers.watchlist)
        persist()
    }

    var canContinueFromPortfolio: Bool { answers.portfolioInterest != nil }

    func continueFromPortfolio() {
        guard canContinueFromPortfolio else { return }
        goTo(.summary)
    }

    // MARK: - ONB-10 Summary / confirmation

    var summaryText: String { Self.buildSummary(answers) }
    var profileRows: [(label: String, value: String)] { Self.profileRows(answers) }

    func buildThesis() {
        goTo(.completion)
    }

    // MARK: - ONB-11 Completion

    func enterThesis() {
        isCompletionTransitioning = true
        Task {
            try? await Task.sleep(nanoseconds: 500_000_000)
            onboardingComplete = true
            persist()
            phase = .appReady
        }
    }

    // MARK: - Navigation

    func goBack() {
        guard let previous = history.popLast() else { return }
        navigationDirection = .backward
        phase = .onboarding(previous)
        persist()
    }

    private func goTo(_ step: OnboardingStepID) {
        if let current = currentStep { history.append(current) }
        navigationDirection = .forward
        phase = .onboarding(step)
        persist()
    }

    // MARK: - Persistence

    private func persist() {
        guard let user else { return }
        let state = OnboardingState(
            user: user,
            answers: answers,
            currentStep: currentStep ?? .name,
            onboardingComplete: onboardingComplete
        )
        persistence.save(state)
        Task {
            do {
                try await supabase.upsertUser(UserRow(state: state))
            } catch {
                #if DEBUG
                print("Supabase sync failed: \(error)")
                #endif
            }
        }
    }

    private func toggle(_ value: String, in array: inout [String]) {
        if let index = array.firstIndex(of: value) {
            array.remove(at: index)
        } else {
            array.append(value)
        }
    }

    // MARK: - Pure derivations (unit-tested directly)

    static func buildSummary(_ answers: OnboardingAnswers) -> String {
        let experiencePhrase: [ExperienceLevel: String] = [
            .gettingStarted: "a new investor",
            .basics: "a developing investor",
            .active: "an active market follower",
            .professional: "a professional investor"
        ]
        let focusPhrase: [String: String] = [
            "Building long-term wealth": "building long-term wealth",
            "Finding my next big idea": "finding your next big idea",
            "Becoming a better investor": "becoming a better investor",
            "Staying ahead of the news": "staying ahead of the news",
            "Understanding companies I already own": "understanding the companies you already own",
            "Building conviction before I act": "building conviction before you act"
        ]
        let horizonPhrase: [TimeHorizon: String] = [
            .days: "a short-term horizon",
            .months: "a short-term horizon",
            .oneToThree: "a medium-term horizon",
            .threeToTen: "a long-term horizon",
            .tenPlus: "a long-term horizon"
        ]

        let experience = answers.experience.flatMap { experiencePhrase[$0] } ?? "an investor"
        let focus = answers.focus.flatMap { focusPhrase[$0] } ?? "building conviction"
        let horizon = answers.horizon.flatMap { horizonPhrase[$0] } ?? "a flexible horizon"
        var extra = ""
        if let firstNeed = answers.infoNeeds.first {
            extra = " and a strong interest in \(firstNeed.lowercased())"
        }
        return "You're \(experience), focused on \(focus), with \(horizon)\(extra)."
    }

    static func deriveStyle(_ behavior: [String]) -> String {
        if behavior.contains("I research companies myself") { return "Research-driven" }
        if behavior.contains("I follow analysts") { return "Analyst-driven" }
        if behavior.contains("I follow the news") { return "News-driven" }
        if behavior.contains("I follow communities / social media") { return "Community-informed" }
        return "Signal-driven"
    }

    static func profileRows(_ answers: OnboardingAnswers) -> [(label: String, value: String)] {
        var rows: [(label: String, value: String)] = [
            ("Experience", OptionData.experience.first { $0.value == answers.experience }?.label ?? "—"),
            ("Focus", answers.focus ?? "—"),
            ("Horizon", OptionData.horizons.first { $0.value == answers.horizon }?.label ?? "—"),
            ("Style", deriveStyle(answers.behavior))
        ]
        if !answers.watchlist.isEmpty {
            rows.append(("Watchlist", answers.watchlist.joined(separator: " · ")))
        }
        return rows
    }
}
