import Foundation
@testable import Thesis

final class MockAuthService: AuthServicing {
    var shouldFail = false

    func signIn(provider: AuthProvider) async throws -> UserAccount {
        if shouldFail { throw AuthError.simulatedFailure }
        return UserAccount(id: "temp-id", firstName: "", authProvider: provider)
    }
}

final class MockSupabaseService: SupabaseServicing {
    private(set) var upsertedRows: [UserRow] = []
    var fetchResult: UserRow?
    var shouldFailUpsert = false

    func upsertUser(_ row: UserRow) async throws {
        if shouldFailUpsert { throw SupabaseError.requestFailed(statusCode: 500) }
        upsertedRows.append(row)
    }

    func fetchUser(id: String) async throws -> UserRow? {
        fetchResult
    }
}
