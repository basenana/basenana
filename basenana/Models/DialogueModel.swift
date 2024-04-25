//
//  MessageModel.swift
//  basenana
//
//  Created by zww on 2024/4/7.
//

import Foundation
import SwiftData
import GRDB

struct RoomModel: Codable {
    var id: Int64?
    var namespace: String?
    var oid: Int64
    var docid: Int64
    var title: String?
    var prompt: String?
    
    var createdAt: Date
}


extension RoomModel: TableRecord {
    
    static var databaseTableName: String = "room"
    
    enum Columns {
        static let id = Column(CodingKeys.id)
        static let namespace = Column(CodingKeys.namespace)
        static let oid = Column(CodingKeys.oid)
        static let docid = Column(CodingKeys.docid)
        static let title = Column(CodingKeys.title)
        static let prompt = Column(CodingKeys.prompt)
        static let createdAt = Column(CodingKeys.createdAt)
    }
}

extension RoomModel: FetchableRecord {}

extension RoomModel: MutablePersistableRecord {}

struct RoomMessageModel: Codable, Identifiable {
    var id: Int64?
    var namespace: String?
    var roomid: Int64
    var sender: String
    var message: String
    
    var sendAt: Date
    var createdAt: Date
}


extension RoomMessageModel: TableRecord {
    
    static var databaseTableName: String = "room_message"
    
    enum Columns {
        static let id = Column(CodingKeys.id)
        static let namespace = Column(CodingKeys.namespace)
        static let roomid = Column(CodingKeys.roomid)
        static let sender = Column(CodingKeys.sender)
        static let message = Column(CodingKeys.message)
        static let createdAt = Column(CodingKeys.createdAt)
    }
}

extension RoomMessageModel: FetchableRecord {}

extension RoomMessageModel: MutablePersistableRecord {}
