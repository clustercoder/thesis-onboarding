import Foundation

enum AuthError: Error, Equatable {
    case simulatedFailure

    var userFacingMessage: String {
        "Something went wrong. Try again."
    }
}

/// Sign-in is simulated for this demo (no GoogleSignIn SDK / AuthenticationServices wired to
/// real credentials) — it reproduces the reference prototype's ~850ms latency and success path
/// so the flow, states, and transitions can be evaluated end-to-end.
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
