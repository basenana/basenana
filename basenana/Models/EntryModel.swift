//
//  Entry.swift
//  basenana
//
//  Created by Hypo on 2024/2/29.
//

import SwiftData
import Foundation
import GRDB

let rootEntryID: Int64 = 1
let inboxEntryID: Int64 = 1024

struct EntryModel: Codable, Identifiable {
    var id: Int64?
    var name: String
    var aliases: String
    var parent: Int64
    var kind: String
    var isGroup: Bool
    var size: Int64
    var version: Int64
    var namespace: String
    var storage: String
    
    var uid: Int64
    var gid: Int64
    var permissions: [String]
    
    var createdAt: Date
    var changedAt: Date
    var modifiedAt: Date
    var accessAt: Date
    
    func isVisitable() -> Bool{
        return !name.starts(with: ".")
    }
}


extension EntryModel: TableRecord {
    static var databaseTableName: String = "entry"
    
    enum Columns {
        static let id = Column(CodingKeys.id)
        static let name = Column(CodingKeys.name)
        static let aliases = Column(CodingKeys.aliases)
        static let parent = Column(CodingKeys.parent)
        static let kind = Column(CodingKeys.kind)
        static let isGroup = Column(CodingKeys.isGroup)
        static let size = Column(CodingKeys.size)
        static let version = Column(CodingKeys.version)
        static let namespace = Column(CodingKeys.namespace)
        static let storage = Column(CodingKeys.storage)
        static let uid = Column(CodingKeys.uid)
        static let gid = Column(CodingKeys.gid)
        static let permissions = Column(CodingKeys.permissions)
        static let createdAt = Column(CodingKeys.createdAt)
        static let changedAt = Column(CodingKeys.changedAt)
        static let modifiedAt = Column(CodingKeys.modifiedAt)
        static let accessAt = Column(CodingKeys.accessAt)
    }
}

extension EntryModel: FetchableRecord {}

extension EntryModel: MutablePersistableRecord {
    mutating func didInsert(_ inserted: InsertionSuccess) {
        id = inserted.rowID
    }
}


