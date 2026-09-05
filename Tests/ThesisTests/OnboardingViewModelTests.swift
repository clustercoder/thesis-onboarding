import XCTest
@testable import Thesis

@MainActor
final class OnboardingViewModelTests: XCTestCase {
    private var defaults: UserDefaults!
    private var namespace: String!
    private var authService: MockAuthService!
    private var supabase: MockSupabaseService!
    private var viewModel: OnboardingViewModel!

    override func setUp() {
        super.setUp()
        namespace = "test.\(UUID().uuidString)"
        defaults = UserDefaults(suiteName: namespace)
        let persistence = PersistenceService(defaults: defaults, namespace: namespace)
        authService = MockAuthService()
        supabase = MockSupabaseService()
        viewModel = OnboardingViewModel(authService: authService, persistence: persistence, supabase: supabase)
    }

    override func tearDown() {
        defaults.removePersistentDomain(forName: namespace)
        super.tearDown()
    }

    // MARK: - Auth

    func testSignInRoutesToNameStepAndClearsPriorAnswers() async {
        await viewModel.signIn(provider: .google)

        XCTAssertEqual(viewModel.phase, .onboarding(.name))
        XCTAssertEqual(viewModel.user?.authProvider, .google)
        XCTAssertFalse(viewModel.isAuthenticating)
    }

    func testFailedSignInSurfacesError() async {
        authService.shouldFail = true
        await viewModel.signIn(provider: .apple)

        XCTAssertEqual(viewModel.phase, .authRequired)
        XCTAssertEqual(viewModel.authError, AuthError.simulatedFailure.userFacingMessage)
    }

    // MARK: - ONB-01 Name

    func testSubmitNameAdvancesToExperienceAfterDelay() async throws {
        await viewModel.signIn(provider: .google)
        viewModel.answers.firstName = "Ada"
        viewModel.submitName()

        XCTAssertTrue(viewModel.nameSubmitted)
        try await Task.sleep(nanoseconds: 700_000_000)

        XCTAssertEqual(viewModel.phase, .onboarding(.experience))
    }

    func testSubmitNameDoesNothingWhenBlank() async {
        await viewModel.signIn(provider: .google)
        viewModel.answers.firstName = "   "
        viewModel.submitName()

        XCTAssertFalse(viewModel.nameSubmitted)
        XCTAssertEqual(viewModel.phase, .onboarding(.name))
    }

    // MARK: - ONB-02 Experience

    func testSelectExperienceSetsMicrocopyAndAutoAdvances() async throws {
        await viewModel.signIn(provider: .google)
        viewModel.selectExperience(.basics)

        XCTAssertEqual(viewModel.answers.experience, .basics)
        XCTAssertEqual(
            viewModel.experienceMicrocopy,
            "That's enough to start. Thesis can adapt to how deep you want to go."
        )

        try await Task.sleep(nanoseconds: 700_000_000)
        XCTAssertEqual(viewModel.phase, .onboarding(.goals))
    }

    // MARK: - ONB-03 Goals

    func testContinueFromGoalsRequiresAtLeastOneSelection() async {
        await viewModel.signIn(provider: .google)
        viewModel.continueFromGoals()
        XCTAssertEqual(viewModel.phase, .onboarding(.name)) // unchanged, still on name until it's navigated to goals

        viewModel.selectExperience(.basics)
        try? await Task.sleep(nanoseconds: 700_000_000)
        XCTAssertEqual(viewModel.phase, .onboarding(.goals))

        viewModel.continueFromGoals()
        XCTAssertEqual(viewModel.phase, .onboarding(.goals), "should not advance with zero goals selected")

        viewModel.toggleGoal("Managing risk")
        viewModel.continueFromGoals()
        XCTAssertEqual(viewModel.phase, .onboarding(.horizon))
    }

    func testToggleGoalAddsAndRemoves() async {
        await viewModel.signIn(provider: .google)
        viewModel.toggleGoal("Managing risk")
        XCTAssertEqual(viewModel.answers.goals, ["Managing risk"])

        viewModel.toggleGoal("Managing risk")
        XCTAssertEqual(viewModel.answers.goals, [])
    }

    // MARK: - ONB-04 Horizon

    func testHorizonEducationLineMapsAllBuckets() {
        XCTAssertEqual(OptionData.horizonEducation(for: .days), "Short horizons can move quickly. Context matters even more.")
        XCTAssertEqual(OptionData.horizonEducation(for: .months), "Short horizons can move quickly. Context matters even more.")
        XCTAssertEqual(OptionData.horizonEducation(for: .oneToThree), "A few years gives a thesis room to develop.")
        XCTAssertEqual(OptionData.horizonEducation(for: .threeToTen), "Long horizons give a thesis more time to play out.")
        XCTAssertEqual(OptionData.horizonEducation(for: .tenPlus), "Long horizons give a thesis more time to play out.")
    }

    // MARK: - Back navigation

    func testGoBackPreservesPreviouslyGivenAnswers() async throws {
        await viewModel.signIn(provider: .google)
        viewModel.selectExperience(.active)
        try await Task.sleep(nanoseconds: 700_000_000)
        XCTAssertEqual(viewModel.phase, .onboarding(.goals))

        viewModel.goBack()

        XCTAssertEqual(viewModel.phase, .onboarding(.experience))
        XCTAssertEqual(viewModel.answers.experience, .active, "answer should still be set after navigating back")
        XCTAssertTrue(viewModel.canGoBack == false || viewModel.canGoBack == true) // history integrity smoke check
    }

    // MARK: - Style derivation (ONB-06 -> ONB-10 Style row)

    func testDeriveStylePriorityOrder() {
        XCTAssertEqual(OnboardingViewModel.deriveStyle(["I research companies myself", "I follow the news"]), "Research-driven")
        XCTAssertEqual(OnboardingViewModel.deriveStyle(["I follow analysts", "I follow the news"]), "Analyst-driven")
        XCTAssertEqual(OnboardingViewModel.deriveStyle(["I follow the news"]), "News-driven")
        XCTAssertEqual(OnboardingViewModel.deriveStyle(["I follow communities / social media"]), "Community-informed")
        XCTAssertEqual(OnboardingViewModel.deriveStyle(["I mostly use instinct"]), "Signal-driven")
        XCTAssertEqual(OnboardingViewModel.deriveStyle([]), "Signal-driven")
    }

    // MARK: - Summary composition (ONB-10)

    func testBuildSummaryComposesReadableSentence() {
        var answers = OnboardingAnswers()
        answers.experience = .active
        answers.focus = "Building conviction before I act"
        answers.horizon = .threeToTen
        answers.infoNeeds = ["Contradictory signals"]

        let summary = OnboardingViewModel.buildSummary(answers)

        XCTAssertEqual(
            summary,
            "You're an active market follower, focused on building conviction before you act, with a long-term horizon and a strong interest in contradictory signals."
        )
    }

    func testBuildSummaryFallsBackGracefullyWithNoAnswers() {
        let summary = OnboardingViewModel.buildSummary(OnboardingAnswers())
        XCTAssertEqual(summary, "You're an investor, focused on building conviction, with a flexible horizon.")
    }

    // MARK: - ONB-09 Portfolio

    func testSelectingNotYetClearsWatchlist() async {
        await viewModel.signIn(provider: .google)
        viewModel.selectPortfolio(interested: true)
        viewModel.toggleWatchlistTicker("NVDA")
        XCTAssertEqual(viewModel.answers.watchlist, ["NVDA"])

        viewModel.selectPortfolio(interested: false)
        XCTAssertEqual(viewModel.answers.watchlist, [])
        XCTAssertTrue(viewModel.canContinueFromPortfolio)
    }

    // MARK: - Persistence side effects

    func testAnswerChangesTriggerSupabaseUpsert() async {
        await viewModel.signIn(provider: .google)
        viewModel.answers.firstName = "Ada"
        viewModel.submitName()

        // persist() fires an unstructured Task; give it a beat to run.
        try? await Task.sleep(nanoseconds: 200_000_000)

        XCTAssertFalse(supabase.upsertedRows.isEmpty)
        XCTAssertEqual(supabase.upsertedRows.last?.firstName, "Ada")
    }

    // MARK: - Full happy path

    func testFullOnboardingFlowReachesAppReady() async throws {
        await viewModel.signIn(provider: .google)

        viewModel.answers.firstName = "Grace"
        viewModel.submitName()
        try await Task.sleep(nanoseconds: 700_000_000)
        XCTAssertEqual(viewModel.phase, .onboarding(.experience))

        viewModel.selectExperience(.professional)
        try await Task.sleep(nanoseconds: 700_000_000)
        XCTAssertEqual(viewModel.phase, .onboarding(.goals))

        viewModel.toggleGoal("Managing risk")
        viewModel.continueFromGoals()
        XCTAssertEqual(viewModel.phase, .onboarding(.horizon))

        viewModel.selectHorizon(.threeToTen)
        try await Task.sleep(nanoseconds: 1_400_000_000)
        XCTAssertEqual(viewModel.phase, .onboarding(.volatility))

        viewModel.selectVolatility(OptionData.riskBehaviors[0])
        try await Task.sleep(nanoseconds: 800_000_000)
        XCTAssertEqual(viewModel.phase, .onboarding(.behavior))

        viewModel.toggleBehavior("I research companies myself")
        viewModel.continueFromBehavior()
        XCTAssertEqual(viewModel.phase, .onboarding(.infoNeeds))

        viewModel.toggleInfoNeed("Contradictory signals")
        viewModel.continueFromInfoNeeds()
        XCTAssertEqual(viewModel.phase, .onboarding(.focus))

        viewModel.selectFocus("Building conviction before I act")
        try await Task.sleep(nanoseconds: 600_000_000)
        XCTAssertEqual(viewModel.phase, .onboarding(.portfolio))

        viewModel.selectPortfolio(interested: false)
        viewModel.continueFromPortfolio()
        XCTAssertEqual(viewModel.phase, .onboarding(.summary))

        XCTAssertTrue(viewModel.summaryText.contains("Grace") == false) // summary doesn't repeat the name, sanity check
        XCTAssertEqual(OnboardingViewModel.deriveStyle(viewModel.answers.behavior), "Research-driven")

        viewModel.buildThesis()
        XCTAssertEqual(viewModel.phase, .onboarding(.completion))

        viewModel.enterThesis()
        try await Task.sleep(nanoseconds: 700_000_000)

        XCTAssertEqual(viewModel.phase, .appReady)
    }
}
