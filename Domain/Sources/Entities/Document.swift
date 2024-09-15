//
//  Document.swift
//
//
//  Created by Hypo on 2024/9/13.
//

import Foundation

public protocol DocumentInfo {
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


public protocol DocumentDetail {
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


public struct DocumentUpdate {
    var docId: Int64
    var unread: Bool? = nil
    var marked: Bool? = nil
}

public struct DocumentFilter {
    var all: Bool? = nil
    var parent: Int64? = nil
    var source: String? = nil
    var marked: Bool? = nil
    var unread: Bool? = nil
    var page: Pagination? = nil
    var order: DocumentOrder? = nil
    var orderDesc: Bool? = nil
}

public struct DocumentID {
    var documentID: Int64
    var entryID: Int64
}

public enum DocumentOrder {
    case name
    case source
    case marked
    case unread
    case createdAt
}
