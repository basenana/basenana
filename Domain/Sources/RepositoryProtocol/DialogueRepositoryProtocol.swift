//
//  DialogueRepositoryProtocol.swift
//
//
//  Created by Hypo on 2024/9/15.
//

import Foundation
import Entities


protocol DialogueRepositoryProtocol {
    func ListRoomes(entry: Int64) throws -> [Room]
    func OpenRoome(entry: Int64, room: Int64, option: RoomOption) throws -> Room
    func UpdateRoome(room: Int64, option: RoomOption) throws
    func DeleteRoome(room: Int64) throws
    func ClearRoome(room: Int64) throws
    func ChatInRoome(room: Int64, message: String) throws -> RoomMessage
}


