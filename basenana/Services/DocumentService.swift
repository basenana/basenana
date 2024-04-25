//
//  DocumentService.swift
//  basenana
//
//  Created by zww on 2024/3/25.
//

import SwiftData
import Foundation
import SwiftUI
import GRPC
import GRDB

let documentService = DocumentService()

class DocumentService {
    
    func listDocuments() -> [DocumentModel]{
        // TODO: filter by unread
        do {
            let data: [DocumentModel] = try dbInstance.queue.read{ db in
                try DocumentModel.order(Column("createdAt").desc).fetchAll(db)
            }
            return data
        } catch {
            return []
        }
    }
    
    func saveDocument(doc: DocumentModel) {
        var newDoc = doc
        do {
            let _ = try dbInstance.queue.write{ db in
                try newDoc.save(db)
            }
        } catch {
            log.error("[documentService] create local docuemnt failed \(error)")
        }
        
        log.debug("[documentService] created new local ducument \(newDoc.id)")
        
        return
    }
    
    func cleanupLocalDocument(documentID: Int64) {
        log.debug("[documentService] cleanup local document \(documentID)")
        do {
            let _ = try dbInstance.queue.write{ db in
                try DocumentModel.filter(Column("id") == documentID ).deleteAll(db)
                try RoomModel.filter(Column("docid") == documentID).deleteAll(db)
            }
        } catch {
            log.error("[documentService] cleanup local document \(documentID) failed \(error)")
        }
    }
}
