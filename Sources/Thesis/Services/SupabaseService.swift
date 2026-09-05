import Foundation

enum SupabaseError: Error {
    case invalidResponse
    case requestFailed(statusCode: Int)
}

/// Talks to Supabase's PostgREST data API directly over URLSession — no SDK dependency.
/// Best-effort sync layer: the app's local cache (PersistenceService) is always the source
/// of truth for routing, so failures here are logged, never surfaced as blocking UI errors.
protocol SupabaseServicing {
    func upsertUser(_ row: UserRow) async throws
    func fetchUser(id: String) async throws -> UserRow?
}

struct SupabaseService: SupabaseServicing {
    private let session: URLSession
    private let baseURL: URL
    private let apiKey: String
    private let table: String

    init(
        session: URLSession = .shared,
        baseURL: URL = SupabaseConfig.projectURL,
        apiKey: String = SupabaseConfig.publishableKey,
        table: String = SupabaseConfig.usersTable
    ) {
        self.session = session
        self.baseURL = baseURL
        self.apiKey = apiKey
        self.table = table
    }

    private func request(path: String, query: String? = nil) -> URLRequest {
        var url = baseURL.appendingPathComponent("rest/v1/\(path)")
        if let query {
            var components = URLComponents(url: url, resolvingAgainstBaseURL: false)!
            components.query = query
            url = components.url!
        }
        var request = URLRequest(url: url)
        request.setValue(apiKey, forHTTPHeaderField: "apikey")
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        return request
    }

    func upsertUser(_ row: UserRow) async throws {
        var request = request(path: table)
        request.httpMethod = "POST"
        request.setValue("resolution=merge-duplicates,return=minimal", forHTTPHeaderField: "Prefer")
        request.httpBody = try JSONEncoder().encode(row)

        let (_, response) = try await session.data(for: request)
        guard let http = response as? HTTPURLResponse else { throw SupabaseError.invalidResponse }
        guard (200..<300).contains(http.statusCode) else {
            throw SupabaseError.requestFailed(statusCode: http.statusCode)
        }
    }

    func fetchUser(id: String) async throws -> UserRow? {
        let request = request(path: table, query: "id=eq.\(id)&select=*&limit=1")
        let (data, response) = try await session.data(for: request)
        guard let http = response as? HTTPURLResponse else { throw SupabaseError.invalidResponse }
        guard (200..<300).contains(http.statusCode) else {
            throw SupabaseError.requestFailed(statusCode: http.statusCode)
        }
        let rows = try JSONDecoder().decode([UserRow].self, from: data)
        return rows.first
    }
}
