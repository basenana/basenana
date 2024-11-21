//
//  Entry.swift
//  basenana
//
//  Created by Hypo on 2024/2/29.
//

import SwiftData
import Foundation
import Entities

public struct APIEntryInfo: EntryInfo{
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
    
    public init(id: Int64, name: String, kind: String, isGroup: Bool, size: Int64, parentID: Int64, createdAt: Date, changedAt: Date, modifiedAt: Date, accessAt: Date) {
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
        if !self.isGroup {
            return nil
        }
        return APIGroup(id: id, groupName: name, parentID: parentID)
    }
    
}

public struct APIEntryDetail: EntryDetail {
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
    
    public init(id: Int64, name: String, aliases: String, parent: Int64, kind: String, isGroup: Bool, size: Int64, version: Int64, namespace: String, storage: String, uid: Int64, gid: Int64, permissions: [String], createdAt: Date, changedAt: Date, modifiedAt: Date, accessAt: Date, properties: [any Entities.EntryProperty]) {
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
    
}

public struct APIEntryProperty: EntryProperty {
    public var key: String
    
    public var value: String
    
    public var encoded: Bool
    
    public init(key: String, value: String, encoded: Bool) {
        self.key = key
        self.value = value
        self.encoded = encoded
    }
}
