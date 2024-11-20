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
    public var docId: Int64
    public var unread: Bool? = nil
    public var marked: Bool? = nil
    
    public init(docId: Int64) {
        self.docId = docId
    }
}

public struct DocumentFilter {
    public var all: Bool? = nil
    public var parent: Int64? = nil
    public var source: String? = nil
    public var marked: Bool? = nil
    public var unread: Bool? = nil
    public var page: Pagination? = nil
    public var order: DocumentOrder? = nil
    public var orderDesc: Bool? = nil
    
    public init(){ }
}

public struct DocumentID {
    public var documentID: Int64
    public var entryID: Int64
    
    public init(documentID: Int64) {
        self.documentID = documentID
        self.entryID = 0
    }
    
    public init(entryID: Int64) {
        self.entryID = entryID
        self.documentID = 0
    }
}

public enum DocumentOrder {
    case name
    case source
    case marked
    case unread
    case createdAt
}

public enum DocumentPrespective {
    case unread
    case marked
}
