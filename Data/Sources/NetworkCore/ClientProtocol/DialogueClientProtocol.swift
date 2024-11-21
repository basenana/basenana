//
//  DialogueClientProtocol.swift
//
//
//  Created by Hypo on 2024/9/15.
//

import Foundation
import Entities


public protocol DialogueClientProtocol {
    func ListRoomes(entry: Int64) throws -> [APIRoom]
    func OpenRoom(entry: Int64, room: Int64, option: RoomOption) throws -> APIRoom
    func UpdateRoom(room: Int64, option: RoomOption) throws
    func DeleteRoom(room: Int64) throws
    func ClearRoom(room: Int64) throws
    func ChatInRoom(room: Int64, message: String, handler: @escaping (APIRoomMessage, Bool) -> Void) throws
}
