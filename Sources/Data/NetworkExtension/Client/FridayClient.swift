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

    public func chat(message: String, handler: @escaping (FridayStreamEvent) async -> Void) async throws {
        let request = try buildRequest(message: message)

        let (bytes, response) = try await streamSession.bytes(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.networkError(NSError(domain: "FridayClient", code: -1))
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            throw APIError.httpError(statusCode: httpResponse.statusCode, message: "SSE stream error")
        }

        var eventType = ""
        var eventData = ""

        for try await line in bytes.lines {
            if line.hasPrefix("event:") {
                // Dispatch previous event if exists
                if !eventType.isEmpty && !eventData.isEmpty {
                    let event = parseEvent(type: eventType, data: eventData)
                    await handler(event)
                }
                eventType = String(line.dropFirst(6)).trimmingCharacters(in: .whitespaces)
                eventData = ""
            } else if line.hasPrefix("data:") {
                eventData = String(line.dropFirst(5)).trimmingCharacters(in: .whitespaces)
            } else if line.isEmpty && !eventType.isEmpty && !eventData.isEmpty {
                // Empty line indicates end of event
                let event = parseEvent(type: eventType, data: eventData)
                await handler(event)
                eventType = ""
                eventData = ""
            }
        }

        // Handle last event if exists
        if !eventType.isEmpty && !eventData.isEmpty {
            let event = parseEvent(type: eventType, data: eventData)
            await handler(event)
        }
    }

    private func buildRequest(message: String) throws -> URLRequest {
        let baseURL = apiClient.baseURL
        guard let url = URL(string: baseURL + APIEndpoint.chat.path) else {
            throw APIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = APIEndpoint.chat.method.rawValue
        request.timeoutInterval = 3600 // 1 hour for SSE stream
        request.setValue("text/event-stream", forHTTPHeaderField: "Accept")
        request.setValue("no-cache", forHTTPHeaderField: "Cache-Control")

        // Use auth interceptor if available
        if let interceptor = apiClient.authInterceptor {
            request.setValue(interceptor.authorizationHeader, forHTTPHeaderField: "Authorization")
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        }

        let body = FridayChatRequest(message: message)
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
            return .messageAppend(FridayMessageAppend(reasoning: "", content: data))

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
}
