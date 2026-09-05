import Foundation

enum AuthError: Error, Equatable {
    case simulatedFailure

    var userFacingMessage: String {
        "Something went wrong. Try again."
    }
}

/// Lightweight stub standing in for real Google/Apple sign-in (no GoogleSignIn SDK /
/// AuthenticationServices wired to actual credentials yet) — it models the ~850ms latency and
/// success path of a real provider round trip so the flow, states, and transitions can be
/// evaluated end-to-end. Swapping in real providers only requires a new `AuthServicing`
/// conformance; nothing else in the app depends on this implementation.
protocol AuthServicing {
    func signIn(provider: AuthProvider) async throws -> UserAccount
}

struct AuthService: AuthServicing {
    func signIn(provider: AuthProvider) async throws -> UserAccount {
        try await Task.sleep(nanoseconds: 850_000_000)
        let id = UUID().uuidString
        return UserAccount(id: id, firstName: "", authProvider: provider)
    }
}
