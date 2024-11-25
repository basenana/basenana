//
//  DialogueRepository.swift
//
//
//  Created by Hypo on 2024/9/14.
//

import Foundation
import Entities
import NetworkCore
import RepositoryProtocol


public class DialogueRepository: DialogueRepositoryProtocol {
    private var core: DialogueClientProtocol
    
    init(core: DialogueClientProtocol) throws {
        self.core = core
    }
    
    public func ListRoomes(entry: Int64) async throws -> [any Entities.Room] {
        return try await core.ListRoomes(entry: entry)
    }
    
    public func OpenRoom(entry: Int64, room: Int64, option: Entities.RoomOption) async throws -> any Entities.Room {
        return try await core.OpenRoom(entry: entry, room: room, option: option)
    }
    
    public func UpdateRoom(room: Int64, option: Entities.RoomOption) async throws {
        return try await core.UpdateRoom(room: room, option: option)
    }
    
    public func DeleteRoom(room: Int64) async throws {
        return try await core.DeleteRoom(room: room)
    }
    
    public func ClearRoom(room: Int64) async throws {
        return try await core.ClearRoom(room: room)
    }
    
    public func ChatInRoom(room: Int64, message: String, handler: @escaping (Entities.RoomMessage, Bool) async -> Void) async throws {
        return try await core.ChatInRoom(room: room, message: message){ msg, next in
            await handler(msg, next)
        }
    }
    
}
