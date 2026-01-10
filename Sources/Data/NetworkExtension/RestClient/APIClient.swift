//
//  APIClient.swift
//  Data
//
//  Base REST API client using URLSession
//

import Foundation
import os

public enum APIError: Error, LocalizedError {
    case invalidURL
    case noData
    case decodingError(Error)
    case httpError(statusCode: Int, message: String?)
    case networkError(Error)
    case unauthorized
    case notFound
    case serverError
    case timeout

    public var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .noData:
            return "No data received"
        case .decodingError(let error):
            return "Decoding error: \(error.localizedDescription)"
        case .httpError(let statusCode, let message):
            return "HTTP \(statusCode): \(message ?? "Unknown error")"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .unauthorized:
            return "Unauthorized"
        case .notFound:
            return "Not found"
        case .serverError:
            return "Server error"
        case .timeout:
            return "Request timed out"
        }
    }
}

final public class APIClient {
    public static let shared = APIClient()

    private let session: URLSession
    private let baseURL: String
    private var authInterceptor: AuthInterceptor?

    private static let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier!,
        category: "APIClient"
    )

    /// Default timeout for requests (in seconds)
    public var requestTimeout: TimeInterval = 10

    private init() {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 10
        configuration.timeoutIntervalForResource = 300
        self.session = URLSession(configuration: configuration)
        self.baseURL = ""
    }

    init(baseURL: String, username: String, password: String, timeout: TimeInterval = 10) {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = timeout
        configuration.timeoutIntervalForResource = 300
        self.session = URLSession(configuration: configuration)
        self.baseURL = baseURL
        self.authInterceptor = AuthInterceptor(username: username, password: password)
        self.requestTimeout = timeout
    }

    func setAuth(username: String, password: String) {
        self.authInterceptor = AuthInterceptor(username: username, password: password)
    }

    // MARK: - Generic Request Methods

    public func request<T: Decodable>(_ endpoint: APIEndpoint, responseType: T.Type) async throws -> T {
        let request = try buildRequest(endpoint)
        let (data, response) = try await performRequestWithTimeout(request)
        return try decodeResponse(data: data, response: response)
    }

    public func request<T: Decodable, B: Encodable>(_ endpoint: APIEndpoint, body: B, responseType: T.Type) async throws -> T {
        var request = try buildRequest(endpoint)
        request.httpBody = try JSONEncoder.encodeWithNilOmit(body)
        let (data, response) = try await performRequestWithTimeout(request)
        return try decodeResponse(data: data, response: response)
    }

    public func requestData(_ endpoint: APIEndpoint) async throws -> Data {
        let request = try buildRequest(endpoint)
        let (data, response) = try await performRequestWithTimeout(request)

        guard let httpResponse = response as? HTTPURLResponse else {
            Self.logger.error("invalid response type")
            throw APIError.networkError(NSError(domain: "APIClient", code: -1))
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            let message = String(data: data, encoding: .utf8) ?? "nil"
            Self.logger.error("HTTP \(httpResponse.statusCode): \(message)")
            throw APIError.httpError(statusCode: httpResponse.statusCode, message: message)
        }

        return data
    }

    func uploadFile(_ endpoint: APIEndpoint, fileData: Data, fileName: String, mimeType: String) async throws -> Data {
        var request = try buildRequest(endpoint)

        let boundary = UUID().uuidString
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        var body = Data()
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"file\"; filename=\"\(fileName)\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: \(mimeType)\r\n\r\n".data(using: .utf8)!)
        body.append(fileData)
        body.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)

        request.httpBody = body

        let (data, response) = try await performRequest(request)
        return data
    }

    // MARK: - Private Helpers

    private func buildRequest(_ endpoint: APIEndpoint) throws -> URLRequest {
        var urlComponents = URLComponents(string: baseURL + endpoint.path)
        let queryItems = endpoint.queryItems().filter { $0.value != nil }
        if !queryItems.isEmpty {
            urlComponents?.queryItems = queryItems
        }

        guard let url = urlComponents?.url else {
            throw APIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method.rawValue

        if let interceptor = authInterceptor {
            interceptor.configureRequest(&request)
        } else {
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.setValue("application/json", forHTTPHeaderField: "Accept")
        }

        return request
    }

    private func performRequest(_ request: URLRequest) async throws -> (Data, URLResponse) {
        do {
            return try await session.data(for: request)
        } catch {
            Self.logger.error("network error: \(error.localizedDescription)")
            throw APIError.networkError(error)
        }
    }

    private func performRequestWithTimeout(_ request: URLRequest) async throws -> (Data, URLResponse) {
        return try await withThrowingTaskGroup(of: (Data, URLResponse).self) { group in
            group.addTask {
                try await self.session.data(for: request)
            }

            group.addTask {
                try await Task.sleep(nanoseconds: UInt64(self.requestTimeout * 1_000_000_000))
                throw APIError.timeout
            }

            let result = try await group.next()!
            group.cancelAll()
            return result
        }
    }

    private func decodeResponse<T: Decodable>(data: Data, response: URLResponse) throws -> T {
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.networkError(NSError(domain: "APIClient", code: -1))
        }

        switch httpResponse.statusCode {
        case 200...299:
            do {
                return try JSONDecoder.apiDecoder.decode(T.self, from: data)
            } catch {
                throw APIError.decodingError(error)
            }
        case 401:
            throw APIError.unauthorized
        case 404:
            throw APIError.notFound
        case 500...599:
            throw APIError.serverError
        default:
            let message = String(data: data, encoding: .utf8)
            throw APIError.httpError(statusCode: httpResponse.statusCode, message: message)
        }
    }
}

// MARK: - JSON Decoder Extension

extension JSONDecoder {
    static let apiDecoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }()
}

// MARK: - JSON Encoder Extension

extension JSONEncoder {
    static let apiEncoder: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        return encoder
    }()

    static func encodeWithNilOmit<T: Encodable>(_ value: T) throws -> Data {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let container = try encoder.encode(value)
        return try filterNilValues(in: container)
    }

    private static func filterNilValues(in data: Data) throws -> Data {
        guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            return data
        }
        let filtered = json.filter { $0.value is NSNull == false }
        return try JSONSerialization.data(withJSONObject: filtered)
    }
}

// MARK: - Error Response Model

struct APIErrorResponse: Decodable {
    let error: String
}
