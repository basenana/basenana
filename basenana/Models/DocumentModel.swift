//
//  document.swift
//  basenana
//
//  Created by zww on 2024/3/4.
//

import SwiftData
import Foundation
import GRDB

struct DocumentInfoModel: Codable, Identifiable, Hashable{
    var id: Int64
    var oid: Int64
    var parentId: Int64
    var name: String
    var namespace: String
    var source: String?
    var marked: Bool
    var unread: Bool
    var subContent: String
    
    var createdAt: Date
    var changedAt: Date
}

struct DocumentDetailModel: Codable, Identifiable, Hashable{
    var id: Int64
    var oid: Int64
    var parentId: Int64
    var name: String
    var namespace: String
    var source: String?
    var marked: Bool
    var unread: Bool
    
    var keyWords : [String]?
    var content: String
    var summary: String?
    
    var createdAt: Date
    var changedAt: Date
}

struct Docfilter {
    var unread: Bool?
    var marked: Bool?
}

struct DocumentOrder {
    var order: DocOrder
    var desc: Bool
}

enum DocOrder {
    case createAt
    case name
}

struct DocumentUpdate {
    var docId: Int64
    var unread: Bool?
    var marked: Bool?
}
