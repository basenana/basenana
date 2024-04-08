//
//  MessageModel.swift
//  basenana
//
//  Created by zww on 2024/4/7.
//

import Foundation
import SwiftData

@Model
class DialogueModel: Identifiable {
    @Attribute(.unique) var id: Int64
    var oid: Int64
    var docid: Int64
    var messages: String
    
    var createdAt: Date
    var changedAt: Date
    
    init(id: Int64, oid: Int64, docid: Int64, messages: String) {
        self.id = id
        self.oid = oid
        self.docid = docid
        self.messages = messages
        
        let nowAt = Date.now
        self.createdAt = nowAt
        self.changedAt = nowAt
    }
}
