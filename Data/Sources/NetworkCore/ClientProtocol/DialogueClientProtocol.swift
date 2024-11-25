//
//  DialogueClientProtocol.swift
//
//
//  Created by Hypo on 2024/9/15.
//

import Foundation
import Entities


public protocol DialogueClientProtocol {
    func ListRoomes(entry: Int64) async throws -> [APIRoom]
    func OpenRoom(entry: Int64, room: Int64, option: RoomOption) async throws -> APIRoom
    func UpdateRoom(room: Int64, option: RoomOption) async throws
    func DeleteRoom(room: Int64) async throws
    func ClearRoom(room: Int64) async throws
    func ChatInRoom(room: Int64, message: String, handler: @escaping (APIRoomMessage, Bool) async -> Void) async throws
}
