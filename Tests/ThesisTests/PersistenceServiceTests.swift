import XCTest
@testable import Thesis

final class PersistenceServiceTests: XCTestCase {
    private var defaults: UserDefaults!
    private var namespace: String!
    private var sut: PersistenceService!

    override func setUp() {
        super.setUp()
        namespace = "test.\(UUID().uuidString)"
        defaults = UserDefaults(suiteName: namespace)
        sut = PersistenceService(defaults: defaults, namespace: namespace)
    }

    override func tearDown() {
        sut.clear()
        defaults.removePersistentDomain(forName: namespace)
        super.tearDown()
    }

    func testNoLocalUserIdInitially() {
        XCTAssertNil(sut.localUserId)
        XCTAssertNil(sut.loadState())
    }

    func testCreateLocalUserIdPersistsAcrossInstances() {
        let id = sut.createLocalUserId()

        let secondInstance = PersistenceService(defaults: defaults, namespace: namespace)
        XCTAssertEqual(secondInstance.localUserId, id)
    }

    func testSaveAndLoadStateRoundTrips() {
        var state = OnboardingState()
        state.user = UserAccount(id: "u1", firstName: "Ada", authProvider: .apple)
        state.answers.firstName = "Ada"
        state.answers.goals = ["Managing risk"]
        state.currentStep = .goals
        state.onboardingComplete = false

        sut.save(state)
        let loaded = sut.loadState()

        XCTAssertEqual(loaded, state)
    }

    func testClearRemovesStateAndSessionId() {
        sut.createLocalUserId()
        sut.save(OnboardingState())

        sut.clear()

        XCTAssertNil(sut.localUserId)
        XCTAssertNil(sut.loadState())
    }

    // MARK: - New vs. returning routing (AppPhase.resolve)

    func testResolveWithNoLocalUserGoesToAuthRequired() {
        let phase = AppPhase.resolve(localUserId: nil, cachedState: nil)
        XCTAssertEqual(phase, .authRequired)
    }

    func testResolveWithSessionButNoCacheStartsAtNameStep() {
        let phase = AppPhase.resolve(localUserId: "device-1", cachedState: nil)
        XCTAssertEqual(phase, .onboarding(.name))
    }

    func testResolveWithIncompleteOnboardingResumesAtSavedStep() {
        var state = OnboardingState()
        state.currentStep = .behavior
        state.onboardingComplete = false

        let phase = AppPhase.resolve(localUserId: "device-1", cachedState: state)
        XCTAssertEqual(phase, .onboarding(.behavior))
    }

    func testResolveWithCompleteOnboardingBypassesToAppReady() {
        var state = OnboardingState()
        state.currentStep = .summary
        state.onboardingComplete = true

        let phase = AppPhase.resolve(localUserId: "device-1", cachedState: state)
        XCTAssertEqual(phase, .appReady, "a returning, fully-onboarded user must skip straight past Auth and Onboarding")
    }
}
