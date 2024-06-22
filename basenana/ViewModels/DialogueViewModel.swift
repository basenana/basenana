//
//  DialogueViewModel.swift
//  basenana
//
//  Created by zww on 2024/4/19.
//

import Foundation

@Observable
class DialogueViewModel {
    var messageToSend: String = ""
    var newReply: String = ""
    var messages: [RoomMessageModel] = []
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
