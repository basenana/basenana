//
//  DocumentService.swift
//  basenana
//
//  Created by zww on 2024/3/25.
//

import SwiftData
import Foundation
import SwiftUI

let documentService = DocumentService()

class DocumentService {
    
    func listDocuments() -> [DocumentModel]{
        // TODO: filter by unread
        do {
            let data: [DocumentModel] = try dbInstance.queue.read{ db in
                try DocumentModel.fetchAll(db)
            }
            return data
        } catch {
            return []
        }
    }
    
    func saveDocument(name: String, content: String) {
        let mockedId = Int64(Date().timeIntervalSince1970)
        var newDoc = DocumentModel(id: mockedId, oid: mockedId, name: name, parentEntry: Int64(1), source: "collect", content: content, createdAt: Date(), changedAt: Date())
        
        do {
            try dbInstance.queue.write{ db in
                try newDoc.insert(db)
            }
        } catch {
            
        }
        
        return
    }
}
