//
//  FridayRepository.swift
//  Data
//
//  Repository implementation for Friday AI Chat
//

import Foundation
import Domain

public class FridayRepository: FridayRepositoryProtocol {

    private let client: FridayClientProtocol

    public init(client: FridayClientProtocol) {
        self.client = client
    }

    public func chat(message: String, sessionId: String, name: String?, contextEntries: [String]?, handler: @escaping (FridayChatEvent) async -> Void) async throws {
        try await client.chat(message: message, sessionId: sessionId, name: name, contextEntries: contextEntries) { event in
            let domainEvent = self.convertToDomainEvent(event)
            await handler(domainEvent)
        }
    }

    private func convertToDomainEvent(_ event: FridayStreamEvent) -> FridayChatEvent {
        switch event {
        case .messageAppend(let apiMessage):
            let message = FridayMessage(
                reasoning: apiMessage.reasoning,
                content: apiMessage.content
            )
            return .message(message)

        case .eventUpdate(let apiEvent):
            let dateFormatter = ISO8601DateFormatter()
            let time: Date?
            if let timeString = apiEvent.time {
                time = dateFormatter.date(from: timeString)
            } else {
                time = nil
            }

            #if DEBUG
            print("[FridayRepository] eventUpdate: id=\(apiEvent.id ?? "nil"), event=\(apiEvent.event ?? "nil"), entryUri=\(apiEvent.entryUri ?? "nil")")
            #endif

            let domainEvent = FridayEvent(
                id: apiEvent.id,
                event: apiEvent.event,
                entryUri: apiEvent.entryUri,
                time: time
            )
            return .event(domainEvent)

        case .done:
            return .done
        }
    }

    public func sessions() async throws -> [FridaySession] {
        let sessionDTOs = try await client.getSessions()
        return sessionDTOs.map { convertToDomainSession($0) }
    }

    public func session(id: String) async throws -> (meta: FridaySession, messages: [FridaySessionMessage]) {
        let detailDTO = try await client.getSession(id: id)
        let meta = convertToDomainSession(detailDTO.meta)
        let messages = detailDTO.messages.map { convertToDomainSessionMessage($0) }
        return (meta, messages)
    }

    public func createSession(name: String) async throws -> FridaySession {
        let sessionDTO = try await client.createSession(name: name)
        return convertToDomainSession(sessionDTO)
    }

    public func deleteSession(id: String) async throws {
        try await client.deleteSession(id: id)
    }

    private func convertToDomainSession(_ dto: FridaySessionDTO) -> FridaySession {
        let dateFormatter = ISO8601DateFormatter()
        let createdAt = dateFormatter.date(from: dto.createdAt) ?? Date()
        let updatedAt = dto.updatedAt.flatMap { dateFormatter.date(from: $0) } ?? createdAt

        return FridaySession(
            id: dto.id,
            name: dto.name,
            createdAt: createdAt,
            updatedAt: updatedAt
        )
    }

    private func convertToDomainSessionMessage(_ dto: FridaySessionMessageDTO) -> FridaySessionMessage {
        let dateFormatter = ISO8601DateFormatter()
        let time = dateFormatter.date(from: dto.time) ?? Date()

        return FridaySessionMessage(
            type: dto.type,
            content: dto.content,
            reasoning: dto.reasoning,
            toolName: dto.toolName,
            time: time
        )
    }
}
