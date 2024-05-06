//
//  EntryProperty.swift
//  basenana
//
//  Created by zww on 2024/5/5.
//

import SwiftData
import Foundation
import GRDB

struct EntryPropertyModel: Codable, Identifiable {
    var id: Int64?
    var oid: Int64
    var key: String
    var value : String
    var encoded: Bool
    
    var syncAt: Date
}

extension EntryPropertyModel: TableRecord {
    static var databaseTableName: String = "entry_property"
    
    enum Columns {
        static let id = Column(CodingKeys.id)
        static let oid = Column(CodingKeys.oid)
        static let key = Column(CodingKeys.key)
        static let value = Column(CodingKeys.value)
        static let encoded = Column(CodingKeys.encoded)
        static let syncAt = Column(CodingKeys.syncAt)
    }
}

extension EntryPropertyModel: FetchableRecord {}

extension EntryPropertyModel: MutablePersistableRecord {}


