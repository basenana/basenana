//
//  MessageModel.swift
//  basenana
//
//  Created by zww on 2024/4/7.
//

import Foundation
import SwiftData
import GRDB

struct DialogueModel: Codable {
    var id: Int64?
    var oid: Int64
    var docid: Int64
    var messages: [[String: String]]=[]
    
    var createdAt: Date
    var changedAt: Date
}


extension DialogueModel: TableRecord {
    
    static var databaseTableName: String = "dialogue"
    
    enum Columns {
        static let id = Column(CodingKeys.id)
        static let oid = Column(CodingKeys.oid)
        static let docid = Column(CodingKeys.docid)
        static let messages = Column(CodingKeys.messages)
        static let createdAt = Column(CodingKeys.createdAt)
        static let changedAt = Column(CodingKeys.changedAt)
    }
}

extension DialogueModel: FetchableRecord {}

extension DialogueModel: MutablePersistableRecord {
    mutating func didInsert(_ inserted: InsertionSuccess) {
        id = inserted.rowID
    }
}
