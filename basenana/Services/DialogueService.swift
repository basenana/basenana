//
//  MessageService.swift
//  basenana
//
//  Created by zww on 2024/4/7.
//

import Foundation
import SwiftData
import GRDB

let dialogueService = DialogueService()

class DialogueService: ObservableObject {
    
    func getDialogue(docId: Int64) -> DialogueModel? {
        do {
            let data: DialogueModel? = try dbInstance.queue.read{ db in
                try DialogueModel.filter(Column("docid") == docId).fetchOne(db)
            }
            return data
        } catch {
            return nil
        }
    }
    
    func saveMessage(docId: Int64, user: String, content: String) {
        var dialogue: DialogueModel?
        do {
            let data: DialogueModel? = try dbInstance.queue.read{ db in
                try DialogueModel.filter(Column("docid") == docId).fetchOne(db)
            }
            dialogue = data
        } catch {
            return
        }
        
        let newMessage = ["user": user, "content": content]
        if dialogue == nil {
            let mockedId = Int64(Date().timeIntervalSince1970)
            dialogue = DialogueModel(id: mockedId, oid: docId, docid: docId, messages: [newMessage], createdAt: Date(), changedAt: Date())
        } else {
            dialogue?.messages.append(newMessage)
        }
        
        do {
            try dbInstance.queue.write{ db in
                try dialogue?.save(db)
            }
        } catch {
            log.error("insert document to inbox failed \(error)")
        }
        return
    }
    
    
    func clearMessage(docId: Int64) {
        do {
            try dbInstance.queue.write{ db in
                var dialogue: DialogueModel? = try DialogueModel.filter(Column("docid") == docId).fetchOne(db)
                if dialogue != nil{
                    dialogue?.messages = []
                    try dialogue?.save(db)
                }
            }
        }catch{
            log.error("get dialogue by docId \(docId) failed \(error)")
        }
    }
}
