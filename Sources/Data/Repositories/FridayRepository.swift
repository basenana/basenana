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

    public func chat(message: String, handler: @escaping (FridayChatEvent) async -> Void) async throws {
        try await client.chat(message: message) { event in
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
            let time = dateFormatter.date(from: apiEvent.time)

            let extraValue: FridayExtraValueDomain?
            if let apiExtra = apiEvent.extraValue {
                extraValue = FridayExtraValueDomain(
                    name: apiExtra.name,
                    arguments: apiExtra.arguments
                )
            } else {
                extraValue = nil
            }

            let event = FridayEvent(
                id: apiEvent.id,
                type: apiEvent.type,
                source: apiEvent.source,
                data: apiEvent.data,
                extraValue: extraValue,
                time: time
            )
            return .event(event)

        case .done:
            return .done
        }
    }
}
