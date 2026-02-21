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

        var currentEventType = ""
        var currentEventData = ""

        for try await line in bytes.lines {
            #if DEBUG
            print("[FridayClient] Received line: [len=\(line.count)] \(line)")
            #endif
            if line.hasPrefix("event:") {
                currentEventType = String(line.dropFirst(6)).trimmingCharacters(in: .whitespaces)
                currentEventData = ""
            } else if line.hasPrefix("data:") {
                currentEventData = String(line.dropFirst(5)).trimmingCharacters(in: .whitespaces)

                let event = parseEvent(type: currentEventType, data: currentEventData)
                #if DEBUG
                print("[FridayClient] Parsed event type: \(currentEventType), isDone: \(event.isDone), dataLen=\(currentEventData.count)")
                #endif
                await handler(event)

                currentEventData = ""
            }
        }

        // Handle final EVENT-UPDATE at stream end
        if !currentEventType.isEmpty && !currentEventData.isEmpty {
            let event = parseEvent(type: currentEventType, data: currentEventData)
            #if DEBUG
            print("[FridayClient] Parsed final event type: \(currentEventType), dataLen=\(currentEventData.count)")
            #endif
            await handler(event)
        }

        #if DEBUG
        print("[FridayClient] Stream ended, sending .done")
        #endif
        // Send done event when stream ends
        await handler(.done)
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
        #if DEBUG
        print("[FridayClient] parseEvent JSON: \(data)")
        #endif
        // Note: Don't use .convertFromSnakeCase here - FridayEventUpdate already has manual CodingKeys
        let decoder = JSONDecoder()

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
                #if DEBUG
                print("[FridayClient] EVENT-UPDATE decoded: id=\(eventUpdate.id ?? "nil"), event=\(eventUpdate.event ?? "nil"), entryUri=\(eventUpdate.entryUri ?? "nil")")
                #endif
                return .eventUpdate(eventUpdate)
            }
            #if DEBUG
            print("[FridayClient] EVENT-UPDATE decode FAILED, data: \(data)")
            #endif
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
