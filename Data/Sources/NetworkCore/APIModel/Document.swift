//
//  document.swift
//  basenana
//
//  Created by zww on 2024/3/4.
//

import SwiftData
import Foundation
import Entities

public struct APIDocumentInfo: DocumentInfo {
    public var id: Int64
    
    public var oid: Int64
    
    public var parentId: Int64
    
    public var name: String
    
    public var namespace: String
    
    public var source: String?
    
    public var marked: Bool
    
    public var unread: Bool
    
    public var subContent: String
    
    public var createdAt: Date
    
    public var changedAt: Date
    
    public init(id: Int64, oid: Int64, parentId: Int64, name: String, namespace: String, source: String? = nil, marked: Bool, unread: Bool, subContent: String, createdAt: Date, changedAt: Date) {
        self.id = id
        self.oid = oid
        self.parentId = parentId
        self.name = name
        self.namespace = namespace
        self.source = source
        self.marked = marked
        self.unread = unread
        self.subContent = subContent
        self.createdAt = createdAt
        self.changedAt = changedAt
    }
}


public struct APIDocumentDetail: DocumentDetail {
    public var id: Int64
    
    public var oid: Int64
    
    public var parentId: Int64
    
    public var name: String
    
    public var namespace: String
    
    public var source: String?
    
    public var marked: Bool
    
    public var unread: Bool
    
    public var keyWords: [String]?
    
    public var content: String
    
    public var summary: String?
    
    public var createdAt: Date
    
    public var changedAt: Date
    
    public init(id: Int64, oid: Int64, parentId: Int64, name: String, namespace: String, source: String? = nil, marked: Bool, unread: Bool, keyWords: [String]? = nil, content: String, summary: String? = nil, createdAt: Date, changedAt: Date) {
        self.id = id
        self.oid = oid
        self.parentId = parentId
        self.name = name
        self.namespace = namespace
        self.source = source
        self.marked = marked
        self.unread = unread
        self.keyWords = keyWords
        self.content = content
        self.summary = summary
        self.createdAt = createdAt
        self.changedAt = changedAt
    }
}
