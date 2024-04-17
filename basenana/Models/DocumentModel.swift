//
//  document.swift
//  basenana
//
//  Created by zww on 2024/3/4.
//

import SwiftData
import Foundation
import GRDB

struct DocumentModel: Codable, Identifiable, Hashable{
    var id: Int64?
    var oid: Int64
    var name: String
    var parentEntry: Int64
    var source: String?
    
    var keyWords : [String]?
    var content: String
    var summary: String?
    
    var createdAt: Date
    var changedAt: Date
}

extension DocumentModel: TableRecord {
    static var databaseTableName: String = "document"
    
    enum Columns {
        static let id = Column(CodingKeys.id)
        static let oid = Column(CodingKeys.oid)
        static let name = Column(CodingKeys.name)
        static let parentEntry = Column(CodingKeys.parentEntry)
        static let source = Column(CodingKeys.source)
        static let keyWords = Column(CodingKeys.keyWords)
        static let content = Column(CodingKeys.content)
        static let createdAt = Column(CodingKeys.createdAt)
        static let changedAt = Column(CodingKeys.changedAt)
    }
}

extension DocumentModel: FetchableRecord {}

extension DocumentModel: MutablePersistableRecord {
    mutating func didInsert(_ inserted: InsertionSuccess) {
        if id == nil{
            id = inserted.rowID
        }
    }
}
