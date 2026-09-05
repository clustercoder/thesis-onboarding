import XCTest
@testable import Thesis

/// Intercepts every request so these tests never touch the real network.
final class StubURLProtocol: URLProtocol {
    static var handler: ((URLRequest) -> (HTTPURLResponse, Data))?

    override class func canInit(with request: URLRequest) -> Bool { true }
    override class func canonicalRequest(for request: URLRequest) -> URLRequest { request }

    override func startLoading() {
        guard let handler = Self.handler else {
            client?.urlProtocol(self, didFailWithError: URLError(.badServerResponse))
            return
        }
        let (response, data) = handler(request)
        client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
        client?.urlProtocol(self, didLoad: data)
        client?.urlProtocolDidFinishLoading(self)
    }

    override func stopLoading() {}
}

final class SupabaseServiceTests: XCTestCase {
    private var session: URLSession!
    private let baseURL = URL(string: "https://example.supabase.co")!
    private let apiKey = "test-key"

    override func setUp() {
        super.setUp()
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [StubURLProtocol.self]
        session = URLSession(configuration: config)
    }

    override func tearDown() {
        StubURLProtocol.handler = nil
        super.tearDown()
    }

    func testUpsertUserSendsCorrectHeadersURLAndBody() async throws {
        var capturedRequest: URLRequest?
        StubURLProtocol.handler = { request in
            capturedRequest = request
            return (HTTPURLResponse(url: request.url!, statusCode: 201, httpVersion: nil, headerFields: nil)!, Data())
        }

        let service = SupabaseService(session: session, baseURL: baseURL, apiKey: apiKey, table: "users")
        var state = OnboardingState()
        state.user = UserAccount(id: "abc-123", firstName: "Ada", authProvider: .google)
        state.answers.firstName = "Ada"
        let row = UserRow(state: state)

        try await service.upsertUser(row)

        let request = try XCTUnwrap(capturedRequest)
        XCTAssertEqual(request.httpMethod, "POST")
        XCTAssertEqual(request.url?.absoluteString, "https://example.supabase.co/rest/v1/users")
        XCTAssertEqual(request.value(forHTTPHeaderField: "apikey"), apiKey)
        XCTAssertEqual(request.value(forHTTPHeaderField: "Authorization"), "Bearer \(apiKey)")
        XCTAssertEqual(request.value(forHTTPHeaderField: "Prefer"), "resolution=merge-duplicates,return=minimal")

        let body = try XCTUnwrap(request.httpBody)
        let decoded = try JSONDecoder().decode(UserRow.self, from: body)
        XCTAssertEqual(decoded.id, "abc-123")
        XCTAssertEqual(decoded.firstName, "Ada")
    }

    func testUpsertUserThrowsOnServerError() async {
        StubURLProtocol.handler = { request in
            (HTTPURLResponse(url: request.url!, statusCode: 500, httpVersion: nil, headerFields: nil)!, Data())
        }
        let service = SupabaseService(session: session, baseURL: baseURL, apiKey: apiKey, table: "users")
        let row = UserRow(state: OnboardingState())

        do {
            try await service.upsertUser(row)
            XCTFail("expected an error for a 500 response")
        } catch SupabaseError.requestFailed(let statusCode) {
            XCTAssertEqual(statusCode, 500)
        } catch {
            XCTFail("unexpected error: \(error)")
        }
    }

    func testFetchUserDecodesFirstMatchingRow() async throws {
        let sampleJSON = """
        [{"id":"abc-123","auth_provider":"apple","first_name":"Grace","onboarding_complete":true,"answers":{"firstName":"Grace"}}]
        """.data(using: .utf8)!

        StubURLProtocol.handler = { request in
            XCTAssertTrue(request.url!.absoluteString.contains("id=eq.abc-123"))
            return (HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!, sampleJSON)
        }

        let service = SupabaseService(session: session, baseURL: baseURL, apiKey: apiKey, table: "users")
        let row = try await service.fetchUser(id: "abc-123")

        XCTAssertEqual(row?.firstName, "Grace")
        XCTAssertEqual(row?.onboardingComplete, true)
    }

    func testFetchUserReturnsNilWhenNoRowsMatch() async throws {
        StubURLProtocol.handler = { request in
            (HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!, Data("[]".utf8))
        }
        let service = SupabaseService(session: session, baseURL: baseURL, apiKey: apiKey, table: "users")
        let row = try await service.fetchUser(id: "missing")
        XCTAssertNil(row)
    }
}
