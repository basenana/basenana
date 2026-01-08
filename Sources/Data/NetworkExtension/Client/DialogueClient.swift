//
//  DialogueClient.swift
//
//  REST API placeholder for Dialogue client
//
//  NOTE: Streaming chat functionality is not supported in REST API.
//  This client is marked as unavailable until SSE or polling is implemented.
//

import Foundation
import Domain
import Data

@available(*, unavailable, message: "Dialogue/Room streaming chat is not supported in REST API. Use polling or SSE implementation.")
public class DialogueClient: DialogueClientProtocol {

    public init(apiClient: APIClient) {
        // Initialization not available
    }

    public func ListRoomes(entry: Int64) async throws -> [APIRoom] {
        throw RepositoryError.unimplement
    }

    public func OpenRoom(entry: Int64, room: Int64, option: RoomOption) async throws -> APIRoom {
        throw RepositoryError.unimplement
    }

    public func UpdateRoom(room: Int64, option: RoomOption) async throws {
        throw RepositoryError.unimplement
    }

    public func DeleteRoom(room: Int64) async throws {
        throw RepositoryError.unimplement
    }

    public func ClearRoom(room: Int64) async throws {
        throw RepositoryError.unimplement
    }

    public func ChatInRoom(room: Int64, message: String, handler: @escaping (APIRoomMessage, Bool) async -> Void) async throws {
        throw RepositoryError.unimplement
    }
}
