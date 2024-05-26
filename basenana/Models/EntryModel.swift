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
let inboxEntryID: Int64 = 2

struct EntryInfoModel: Codable, Identifiable {
    var id: Int64
    var name: String
    var kind: String
    var isGroup: Bool
    var size: Int64

    var createdAt: Date
    var changedAt: Date
    var modifiedAt: Date
    var accessAt: Date
    
    func isVisitable() -> Bool{
        return !name.starts(with: ".")
    }
}
struct EntryDetailModel: Codable, Identifiable {
    var id: Int64
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
    
    var properties: [EntryPropertyModel]
    
    func isVisitable() -> Bool{
        return !name.starts(with: ".")
    }
}

enum EntryOrder {
    case createAt
    case modifiedAt
    case name
    case kind
    case size
}

struct EntryFilter {
    var isGroup: Bool?
}

