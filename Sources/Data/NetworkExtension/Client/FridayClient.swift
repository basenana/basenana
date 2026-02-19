//
//  FridayClient.swift
//  Data
//
//  SSE Chat client implementation for Friday AI
//

import Foundation
import Domain

public class FridayClient: FridayClientProtocol {

    private let apiClient: APIClient
    private let streamSession: URLSession

    public init(apiClient: APIClient) {
        self.apiClient = apiClient

        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 3600
        configuration.timeoutIntervalForResource = 3600
        self.streamSession = URLSession(configuration: configuration)
    }

    public func chat(message: String, sessionId: String, name: String?, contextEntries: [String]?, handler: @escaping (FridayStreamEvent) async -> Void) async throws {
        let request = try buildRequest(message: message, sessionId: sessionId, name: name, contextEntries: contextEntries)

        let (bytes, response) = try await streamSession.bytes(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.networkError(NSError(domain: "FridayClient", code: -1))
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            var errorBody = ""
            for try await line in bytes.lines {
                errorBody += line
            }
            throw APIError.httpError(
                statusCode: httpResponse.statusCode,
                message: "\(errorBody)"
            )
        }

        var eventType = ""
        var eventData = ""

        for try await line in bytes.lines {
            if line.hasPrefix("event:") {
                if !eventType.isEmpty && !eventData.isEmpty {
                    let event = parseEvent(type: eventType, data: eventData)
                    await handler(event)
                }
                eventType = String(line.dropFirst(6)).trimmingCharacters(in: .whitespaces)
                eventData = ""
            } else if line.hasPrefix("data:") {
                eventData = String(line.dropFirst(5)).trimmingCharacters(in: .whitespaces)
            } else if line.isEmpty && !eventType.isEmpty && !eventData.isEmpty {
                let event = parseEvent(type: eventType, data: eventData)
                await handler(event)
                eventType = ""
                eventData = ""
            }
        }

        if !eventType.isEmpty && !eventData.isEmpty {
            let event = parseEvent(type: eventType, data: eventData)
            await handler(event)
        }
    }

    private func buildRequest(message: String, sessionId: String, name: String?, contextEntries: [String]?) throws -> URLRequest {
        let baseURL = apiClient.baseURL
        guard let url = URL(string: baseURL + APIEndpoint.chat.path) else {
            throw APIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = APIEndpoint.chat.method.rawValue
        request.timeoutInterval = 3600
        request.setValue("text/event-stream", forHTTPHeaderField: "Accept")
        request.setValue("no-cache", forHTTPHeaderField: "Cache-Control")

        if let interceptor = apiClient.authInterceptor {
            request.setValue(interceptor.authorizationHeader, forHTTPHeaderField: "Authorization")
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        }

        let body = FridayChatRequest(message: message, sessionId: sessionId, name: name, contextEntries: contextEntries)
        request.httpBody = try JSONEncoder().encode(body)

        return request
    }

    private func parseEvent(type: String, data: String) -> FridayStreamEvent {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase

        switch type {
        case "MESSAGE-APPEND":
            if let jsonData = data.data(using: .utf8),
               let messageAppend = try? decoder.decode(FridayMessageAppend.self, from: jsonData) {
                return .messageAppend(messageAppend)
            }
            return .messageAppend(FridayMessageAppend(reasoning: nil, content: nil))

        case "EVENT-UPDATE":
            if let jsonData = data.data(using: .utf8),
               let eventUpdate = try? decoder.decode(FridayEventUpdate.self, from: jsonData) {
                return .eventUpdate(eventUpdate)
            }
            return .done

        case "DONE":
            return .done

        default:
            return .done
        }
    }

    public func getSessions() async throws -> [FridaySessionDTO] {
        let response: FridaySessionsResponse = try await apiClient.request(.fridaySessionList, responseType: FridaySessionsResponse.self)
        return response.sessions
    }

    public func getSession(id: String) async throws -> FridaySessionDetailDTO {
        let response: FridaySessionDetailDTO = try await apiClient.request(.fridaySession(id: id), responseType: FridaySessionDetailDTO.self)
        return response
    }

    public func createSession(name: String) async throws -> FridaySessionDTO {
        let request = FridayCreateSessionRequest(name: name)
        let response: FridaySessionDTO = try await apiClient.request(.fridaySessions, body: request, responseType: FridaySessionDTO.self)
        return response
    }

    public func deleteSession(id: String) async throws {
        let _: EmptyResponse = try await apiClient.request(.fridaySessionDelete(id: id), responseType: EmptyResponse.self)
    }
}

// MARK: - Empty Response

private struct EmptyResponse: Decodable {}
