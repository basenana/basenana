//
//  NotifyClient.swift
//
//  REST API implementation of Notify client
//

import Foundation
import Domain
import Data

public class NotifyClient: NotifyClientProtocol {

    private let apiClient: APIClient

    public init(apiClient: APIClient) {
        self.apiClient = apiClient
    }

    public func ListMessage(all: Bool) async throws -> [APINotification] {
        let response: MessagesResponse = try await apiClient.request(
            .messages(all: all),
            responseType: MessagesResponse.self
        )

        return response.messages.map { dto in
            APINotification(
                id: dto.id,
                title: dto.title,
                message: dto.message,
                type: dto.type,
                source: dto.source,
                action: dto.action,
                status: dto.status,
                time: dto.time
            )
        }
    }

    public func ReadMeesage(id: String) async throws {
        let request = ReadMessagesRequest(message_id_list: [id])
        // Note: API returns {"success": true} but we don't have a proper DTO for this
        _ = try await apiClient.request(
            .messagesRead,
            body: request,
            responseType: MessagesResponse.self
        )
    }
}
