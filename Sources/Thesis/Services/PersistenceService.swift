import Foundation

/// Local cache: a stable per-device session id in the Keychain (survives reinstall), plus a
/// JSON snapshot of onboarding progress in UserDefaults, so a killed app resumes instantly
/// without waiting on a network round-trip to Supabase.
final class PersistenceService {
    private let defaults: UserDefaults
    private let stateKey: String
    private let sessionKeychainKey: String

    init(defaults: UserDefaults = .standard, namespace: String = "com.thesis.onboarding") {
        self.defaults = defaults
        self.stateKey = "\(namespace).state"
        self.sessionKeychainKey = "\(namespace).localUserId"
    }

    var localUserId: String? {
        KeychainStore.read(sessionKeychainKey)
    }

    @discardableResult
    func createLocalUserId() -> String {
        let id = UUID().uuidString
        KeychainStore.write(id, for: sessionKeychainKey)
        return id
    }

    func loadState() -> OnboardingState? {
        guard let data = defaults.data(forKey: stateKey) else { return nil }
        return try? JSONDecoder().decode(OnboardingState.self, from: data)
    }

    func save(_ state: OnboardingState) {
        guard let data = try? JSONEncoder().encode(state) else { return }
        defaults.set(data, forKey: stateKey)
    }

    func clear() {
        defaults.removeObject(forKey: stateKey)
        KeychainStore.delete(sessionKeychainKey)
    }
}
