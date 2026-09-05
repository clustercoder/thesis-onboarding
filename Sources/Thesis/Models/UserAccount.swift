import Foundation

enum AuthProvider: String, Codable {
    case google
    case apple

    var displayLabel: String {
        switch self {
        case .google: "Google"
        case .apple: "Apple"
        }
    }
}

struct UserAccount: Codable, Equatable {
    let id: String
    var firstName: String
    var authProvider: AuthProvider
}
