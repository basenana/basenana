//
//  Doc.swift
//  Domain
//
//  Created by Hypo on 2024/9/22.
//

import Foundation
import Entities

public class MockDocInfo: DocumentInfo {
    public var id: Int64
    
    public var oid: Int64
    
    public var parentId: Int64
    
    public var name: String
    
    public var namespace: String
    
    public var source: String?
    
    public var marked: Bool
    
    public var unread: Bool
    
    public var subContent: String
    
    public var searchContent: [String]
    
    public var headerImage: String

    public var createdAt: Date
    
    public var changedAt: Date
    
    public var properties: [any Entities.EntryProperty]
    
    public var parent: any EntryInfo

    init(id: Int64, oid: Int64, parentId: Int64, name: String, namespace: String, source: String? = nil, marked: Bool, unread: Bool, subContent: String, searchContent: [String], headerImage: String, createdAt: Date, changedAt: Date, properties: [Entities.EntryProperty], parent: EntryInfo) {
        self.id = id
        self.oid = oid
        self.parentId = parentId
        self.name = name
        self.namespace = namespace
        self.source = source
        self.marked = marked
        self.unread = unread
        self.subContent = subContent
        self.searchContent = searchContent
        self.headerImage = headerImage
        self.createdAt = createdAt
        self.changedAt = changedAt
        self.properties = properties
        self.parent = parent
    }
    
}

public class MockDocDetail: DocumentDetail {
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
    
    init(id: Int64, oid: Int64, parentId: Int64, name: String, namespace: String, source: String? = nil, marked: Bool, unread: Bool, keyWords: [String]? = nil, content: String, summary: String? = nil, createdAt: Date, changedAt: Date) {
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
    
    func toInfo() -> MockDocInfo {
        return MockDocInfo(id: id, oid: oid, parentId: parentId, name: name, namespace: namespace, source: source, marked: marked, unread: unread, subContent: content, searchContent: [], headerImage: "", createdAt: createdAt, changedAt: changedAt, properties: [],
                           parent: MockEntryInfo( id: oid, name: name, kind: "file", isGroup: false, size: Int64(1), parentID: parentId, createdAt: createdAt, changedAt: changedAt, modifiedAt: changedAt, accessAt: changedAt))
    }
}


