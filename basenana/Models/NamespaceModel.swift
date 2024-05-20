//
//  NamespaceModel.swift
//  basenana
//
//  Created by zww on 2024/5/19.
//

import Foundation
import GRDB

struct NamespaceModel: Codable{
    var name: String
    var entryId: Int64?
}

extension NamespaceModel: TableRecord {
    static var databaseTableName: String = "namespace"
    
    enum Columns {
        static let name = Column(CodingKeys.name)
        static let entryId = Column(CodingKeys.entryId)
    }
}

extension NamespaceModel: FetchableRecord {}

extension NamespaceModel: MutablePersistableRecord {}
