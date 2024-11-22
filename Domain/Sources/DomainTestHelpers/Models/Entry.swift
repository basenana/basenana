//
//  Entry.swift
//  Domain
//
//  Created by Hypo on 2024/9/22.
//

import Foundation
import Entities

public class MockEntryInfo: EntryInfo {
    public var id: Int64
    
    public var name: String
    
    public var kind: String
    
    public var isGroup: Bool
    
    public var size: Int64
    
    public var parentID: Int64
    
    public var createdAt: Date
    
    public var changedAt: Date
    
    public var modifiedAt: Date
    
    public var accessAt: Date
    
    init(id: Int64, name: String, kind: String, isGroup: Bool, size: Int64, parentID: Int64, createdAt: Date, changedAt: Date, modifiedAt: Date, accessAt: Date) {
        self.id = id
        self.name = name
        self.kind = kind
        self.isGroup = isGroup
        self.size = size
        self.parentID = parentID
        self.createdAt = createdAt
        self.changedAt = changedAt
        self.modifiedAt = modifiedAt
        self.accessAt = accessAt
    }
    
    public func toGroup() -> (any Entities.Group)? {
        if isGroup {
            return MockGroup(id: id, groupName: name, parentID: parentID)
        }
        return nil
    }
    
}

public class MockEntryDetail: EntryDetail {
    
    public var id: Int64
    
    public var name: String
    
    public var aliases: String
    
    public var parent: Int64
    
    public var kind: String
    
    public var isGroup: Bool
    
    public var size: Int64
    
    public var version: Int64
    
    public var namespace: String
    
    public var storage: String
    
    public var uid: Int64
    
    public var gid: Int64
    
    public var permissions: [String]
    
    public var createdAt: Date
    
    public var changedAt: Date
    
    public var modifiedAt: Date
    
    public var accessAt: Date
    
    public var properties: [any Entities.EntryProperty]
    
    
    init(id: Int64, name: String, aliases: String, parent: Int64, kind: String, isGroup: Bool, size: Int64, version: Int64, namespace: String, storage: String, uid: Int64, gid: Int64, permissions: [String], createdAt: Date, changedAt: Date, modifiedAt: Date, accessAt: Date, properties: [any Entities.EntryProperty]) {
        self.id = id
        self.name = name
        self.aliases = aliases
        self.parent = parent
        self.kind = kind
        self.isGroup = isGroup
        self.size = size
        self.version = version
        self.namespace = namespace
        self.storage = storage
        self.uid = uid
        self.gid = gid
        self.permissions = permissions
        self.createdAt = createdAt
        self.changedAt = changedAt
        self.modifiedAt = modifiedAt
        self.accessAt = accessAt
        self.properties = properties
    }
    
    public func toInfo() -> (any Entities.EntryInfo)? {
        return MockEntryInfo(id: id, name: name, kind: kind, isGroup: isGroup, size: size, parentID: parent, createdAt: createdAt, changedAt: changedAt, modifiedAt: modifiedAt, accessAt: accessAt)
    }
    
    public func toGroup() -> (any Entities.Group)? {
        if isGroup {
            return MockGroup(id: id, groupName: name, parentID: parent)
        }
        return nil
    }
}


public class MockGroup: Group {
    
    public var id: Int64
    
    public var groupName: String
    
    public var parentID: Int64
    
    public var children: [any Entities.Group]?

    
    init(id: Int64, groupName: String, parentID: Int64, children: [MockGroup]? = nil) {
        self.id = id
        self.groupName = groupName
        self.parentID = parentID
        self.children = children
    }
}
