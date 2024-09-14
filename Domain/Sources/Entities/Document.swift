//
//  Document.swift
//
//
//  Created by Hypo on 2024/9/13.
//

import Foundation

protocol DocumentInfo {
    var id: Int64 { get }
    var oid: Int64 { get }
    var parentId: Int64 { get }
    var name: String { get }
    var namespace: String { get }
    var source: String? { get }
    var marked: Bool { get }
    var unread: Bool { get }
    var subContent: String { get }
    
    var createdAt: Date { get }
    var changedAt: Date { get }
}


protocol DocumentDetail {
    var id: Int64 { get }
    var oid: Int64 { get }
    var parentId: Int64 { get }
    var name: String { get }
    var namespace: String { get }
    var source: String? { get }
    var marked: Bool { get }
    var unread: Bool { get }
    
    var keyWords : [String]? { get }
    var content: String { get }
    var summary: String? { get }
    
    var createdAt: Date { get }
    var changedAt: Date { get }
}


struct DocumentUpdate {
    var docId: Int64
    var unread: Bool?
    var marked: Bool?
}
