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
    
    public func ListRoomes(entry: Int64) throws -> [any Entities.Room] {
        return try core.ListRoomes(entry: entry)
    }
    
    public func OpenRoom(entry: Int64, room: Int64, option: Entities.RoomOption) throws -> any Entities.Room {
        return try core.OpenRoom(entry: entry, room: room, option: option)
    }
    
    public func UpdateRoom(room: Int64, option: Entities.RoomOption) throws {
        return try core.UpdateRoom(room: room, option: option)
    }
    
    public func DeleteRoom(room: Int64) throws {
        return try core.DeleteRoom(room: room)
    }
    
    public func ClearRoom(room: Int64) throws {
        return try core.ClearRoom(room: room)
    }
    
    public func ChatInRoom(room: Int64, message: String, handler: @escaping (Entities.RoomMessage, Bool) -> Void) throws {
        return try core.ChatInRoom(room: room, message: message){ msg, next in
            handler(msg, next)
        }
    }
    
}
