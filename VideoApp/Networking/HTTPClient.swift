//
//  HTTPClient.swift
//  VideoApp
//
//  Created by Landon Rohatensky on 2025-09-14.
//

import Foundation

/// Lean helpers on URLSession for simple HTTP use cases.
extension URLSession {
    enum HTTPError: LocalizedError {
        case invalidResponse
        case unacceptableStatusCode(Int)

        var errorDescription: String? {
            switch self {
            case .invalidResponse: return "Invalid server response."
            case .unacceptableStatusCode(let code): return "Unacceptable status code: \(code)."
            }
        }
    }

    /// Fetch and decode JSON from a GET request.
    /// Uses URLSession's default configuration (i.e., `URLSession.shared`).
    func json<T: Decodable>(from url: URL,
                            headers: [String: String] = ["Accept": "application/json"],
                            decoder: JSONDecoder = JSONDecoder()) async throws -> T {
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        headers.forEach { request.setValue($0.value, forHTTPHeaderField: $0.key) }

        let (data, response) = try await self.data(for: request)
        guard let http = response as? HTTPURLResponse else { throw HTTPError.invalidResponse }
        guard (200..<300).contains(http.statusCode) else {
            throw HTTPError.unacceptableStatusCode(http.statusCode)
        }
        return try decoder.decode(T.self, from: data)
    }
}
