//
//  DialogueViewModel.swift
//  basenana
//
//  Created by zww on 2024/4/19.
//

import Foundation

class RoomViewModel: Codable {
    var id: Int64
    var oid: Int64
    var docid: Int64
    var title: String?
    var prompt: String?
    
    var createdAt: Date
    
    var messages: [RoomMessageModel] = []
    
    
    init(room: RoomModel, messages: [RoomMessageModel]) {
        self.id = room.id!
        self.oid = room.oid
        self.docid = room.docid
        self.title = room.title
        self.prompt = room.prompt
        self.createdAt = room.createdAt
        self.messages = messages
    }
}

@Observable
class RoomMessageViewModel: Identifiable {
    var id: Int64
    var sender: String
    var message: String
    var sendAt: Date
    
    init(id: Int64, sender: String, message: String, sendAt: Date) {
        self.id = id
        self.sender = sender
        self.message = message
        self.sendAt = sendAt
    }
}
