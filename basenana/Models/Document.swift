//
//  document.swift
//  basenana
//
//  Created by zww on 2024/3/4.
//

import Foundation

struct DocumentInfo{
    var id: Int64
    var oid: Int64
    var name: String
    var parentEntryId: Int64
    var content: String
    var createdAt: Date
    var changedAt: Date
}

struct DocumentDetail{
    var id: Int64
    var oid: Int64
    var name: String
    var parentEntryId: Int64
    var source: String
    var keyWords : [String]?
    var content: String
    var summary: String?
    var desync: Bool
    var createdAt: Date
    var changedAt: Date
}
