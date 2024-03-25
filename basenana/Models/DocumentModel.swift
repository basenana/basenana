//
//  document.swift
//  basenana
//
//  Created by zww on 2024/3/4.
//

import SwiftData
import Foundation

@Model
class DocumentModel: Identifiable{
    @Attribute(.unique) var id: Int64
    var oid: Int64
    var name: String
    var parentEntryId: Int64
    var source: String?
    
    var keyWords : [String]?
    var content: String
    var summary: String?
    var desync: Bool
    
    var createdAt: Date
    var changedAt: Date
    
    init(id: Int64, oid: Int64, name: String, parentEntryId: Int64, source: String, keyWords: [String]? = nil, content: String, summary: String? = nil, desync: Bool) {
        self.id = id
        self.oid = oid
        self.name = name
        self.parentEntryId = parentEntryId
        self.source = source
        self.keyWords = keyWords
        self.content = content
        self.summary = summary
        self.desync = desync
        
        let nowAt = Date.now
        self.createdAt = nowAt
        self.changedAt = nowAt
    }
}
