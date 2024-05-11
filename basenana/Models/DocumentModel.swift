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
    var id: Int64
    var oid: Int64
    var name: String
    var namespace: String
    var parentEntry: Int64
    var source: String?
    var marked: Bool
    var unread: Bool
    
    var keyWords : [String]?
    var content: String
    var summary: String?
    
    var createdAt: Date
    var changedAt: Date
    var syncAt: Date
}

extension DocumentModel: TableRecord {
    static var databaseTableName: String = "document"
    
    enum Columns {
        static let id = Column(CodingKeys.id)
        static let oid = Column(CodingKeys.oid)
        static let name = Column(CodingKeys.name)
        static let namespace = Column(CodingKeys.namespace)
        static let parentEntry = Column(CodingKeys.parentEntry)
        static let source = Column(CodingKeys.source)
        static let marked = Column(CodingKeys.marked)
        static let unread = Column(CodingKeys.unread)
        static let keyWords = Column(CodingKeys.keyWords)
        static let content = Column(CodingKeys.content)
        static let createdAt = Column(CodingKeys.createdAt)
        static let changedAt = Column(CodingKeys.changedAt)
    }
}

extension DocumentModel: FetchableRecord {}

extension DocumentModel: MutablePersistableRecord {}

struct Docfilter {
    var unread: Bool?
    var marked: Bool?
}

struct DocumentUpdate {
    var docId: Int64
    var unread: Bool?
    var marked: Bool?
}
