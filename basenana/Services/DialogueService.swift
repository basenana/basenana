//
//  MessageService.swift
//  basenana
//
//  Created by zww on 2024/4/7.
//

import Foundation
import SwiftData

class DialogueService: ObservableObject {
    
    private var modelContext: ModelContext
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    func getDialogue(docId: Int64) -> DialogueModel? {
        do {
            let data = try modelContext.fetch(FetchDescriptor<DialogueModel>(predicate: #Predicate{$0.docid == docId}))
            if data.first == nil{
                return nil
            }
            return  data.first!
        }catch{
            debugPrint("get dialogue by docId \(docId) failed")
            return nil
        }
    }
    
    func saveMessage(docId: Int64, user: String, content: String) {
        var dialogue: DialogueModel?
        do {
            let data = try modelContext.fetch(FetchDescriptor<DialogueModel>(predicate: #Predicate{$0.docid == docId}))
            if data.first != nil{
                dialogue = data.first!
            }
        }catch{
            debugPrint("get dialogue by docId \(docId) failed")
            return
        }
        
        let newMessage = ["user": user, "content": content]
        if dialogue == nil {
            do {
                let jsonData = try JSONSerialization.data(withJSONObject: [newMessage], options: [])
                let jsonString = String(data: jsonData, encoding: .utf8)
                
                dialogue = DialogueModel(id: genEntryID(), oid: docId, docid: docId, messages: jsonString!)
                
                modelContext.insert(dialogue!)
            } catch {
                debugPrint("Error converting dictionary to JSON: \(error)")
                return
            }
        } else {
            do{
                let messageString = dialogue?.messages
                if messageString == "" {
                    
                    if let data = messageString?.data(using: .utf8) {
                        var messages = try JSONSerialization.jsonObject(with: data, options: []) as? [[String: String]]
                        messages?.append(newMessage)
                        
                        let jsonData = try JSONSerialization.data(withJSONObject: messages, options: [])
                        let jsonString = String(data: jsonData, encoding: .utf8)
                        dialogue!.messages = jsonString!
                        
                    }
                }
                
            } catch {
                debugPrint("Error converting JSON to String: \(error)")
                return
            }
        }
        
        do {
            try modelContext.save()
        } catch {
            debugPrint("insert document to inbox failed")
        }
        return
    }
    
    
    func clearMessage(docId: Int64) {
        var dialogue: DialogueModel
        do {
            let data = try modelContext.fetch(FetchDescriptor<DialogueModel>(predicate: #Predicate{$0.docid == docId}))
            if data.first == nil{
                return
            }
            dialogue = data.first!
            dialogue.messages = ""
        }catch{
            debugPrint("get dialogue by docId \(docId) failed")
            return
        }
        
        do {
            try modelContext.save()
        } catch {
            debugPrint("insert document to inbox failed")
        }
        return
    }
    
    func reflush() {
        self.objectWillChange.send()
    }
}
