//
//  Entry.swift
//  basenana
//
//  Created by Hypo on 2024/2/29.
//

import SwiftData
import Foundation


@Model
final class EntryModel {
    var id: Int64
    var name: String
    var aliases: String
    var parent: Int64
    var kind: String
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
    
    init(id: Int64, name: String, aliases: String, parent: Int64, kind: String, size: Int64, version: Int64, namespace: String, storage: String, uid: Int64, gid: Int64, permissions: [String], createdAt: Date, changedAt: Date, modifiedAt: Date, accessAt: Date) {
        self.id = id
        self.name = name
        self.aliases = aliases
        self.parent = parent
        self.kind = kind
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
    }
}

