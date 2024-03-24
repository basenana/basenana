//
//  Entry.swift
//  basenana
//
//  Created by Hypo on 2024/2/29.
//

import SwiftData
import Foundation

let rootEntryID: Int64 = 1
let inboxEntryID: Int64 = 1024

@Model
class EntryModel: Identifiable {
    @Attribute(.unique) var id: Int64
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
    
    init(id: Int64, name: String = "", aliases: String = "", parent: Int64 = 0, kind: String = "raw", namespace: String = "personal", storage: String = "local", uid: Int64 = 0, gid: Int64 = 0, permissions: [String] = []) {
        self.id = id
        self.name = name
        self.aliases = aliases
        self.parent = parent
        self.kind = kind
        self.size = 0
        self.version = 0
        self.namespace = namespace
        self.storage = storage
        self.uid = uid
        self.gid = gid
        self.permissions = permissions
        
        let nowAt = Date.now
        self.createdAt = nowAt
        self.changedAt = nowAt
        self.modifiedAt = nowAt
        self.accessAt = nowAt
    }
    
    func isGroup() -> Bool {
        return kind == "group"
    }
    
    func isVisitable() -> Bool{
        return !name.starts(with: ".")
    }
}


