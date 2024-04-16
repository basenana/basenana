//
//  SyncModel.swift
//  basenana
//
//  Created by Hypo on 2024/4/15.
//

import Foundation
import SwiftData
import GRDB

struct ConfigModel: Codable {
    var id: Int64?
    var name: String
    var value: String
    var changedAt: Date
}

extension ConfigModel: TableRecord {
    
    static var databaseTableName: String = "config"
    
    enum Columns {
        static let id = Column(CodingKeys.id)
        static let name = Column(CodingKeys.name)
        static let value = Column(CodingKeys.value)
    }
}

extension ConfigModel: FetchableRecord {}

extension ConfigModel: MutablePersistableRecord {
    mutating func didInsert(_ inserted: InsertionSuccess) {
        id = inserted.rowID
    }
}
