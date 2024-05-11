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
    
    func getDocument(entryId: Int64) -> DocumentModel? {
        do {
            let data: DocumentModel? = try dbInstance.queue.read { db in
                try DocumentModel.all().filter(Column("oid") == entryId).fetchOne(db)
            }
            return data
        } catch {
            return nil
        }
    }
    
    func listDocuments(filter: Docfilter) -> [DocumentModel]{
        var data: [DocumentModel]
        do {
            data = try dbInstance.queue.read{ db in
                if let unread = filter.unread {
                    try DocumentModel.filter(Column("unread") == unread).order(Column("createdAt").desc).fetchAll(db)
                } else if let marked = filter.marked {
                    try DocumentModel.filter(Column("marked") == marked).order(Column("createdAt").desc).fetchAll(db)
                } else {
                    try DocumentModel.order(Column("createdAt").desc).fetchAll(db)
                }
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
            log.error("[documentService] save local docuemnt failed \(error)")
        }
        
        log.debug("[documentService] save new local ducument \(newDoc.id)")
        return
    }
    
    func updateDocument(docUpdate: DocumentUpdate) {
        var doc: DocumentModel?
        do {
            doc = try dbInstance.queue.read{ db in
                try DocumentModel.filter(Column("id") == docUpdate.docId).fetchOne(db)
            }
            
            if doc == nil {
                return
            }
            
            var request = Api_V1_UpdateDocumentRequest()
            request.document.id = docUpdate.docId
            if let unread = docUpdate.unread {
                request.setMark = unread ? Api_V1_UpdateDocumentRequest.DocumentMark.unread:Api_V1_UpdateDocumentRequest.DocumentMark.read
                doc?.unread = unread
            }
            if let mark = docUpdate.marked {
                request.setMark = mark ? Api_V1_UpdateDocumentRequest.DocumentMark.marked:Api_V1_UpdateDocumentRequest.DocumentMark.unmarked
                doc?.marked = mark
            }
            
            let _ = clientSet?.document.updateDocument(request, callOptions: nil)
            
            let _ = try dbInstance.queue.write{db in
                try doc?.save(db)
            }
        } catch {
            log.error("[documentService] update docuemnt failed \(error)")
        }
        return
    }
    
    func cleanupLocalDocument(documentID: Int64) {
        log.debug("[documentService] cleanup local document \(documentID)")
        do {
            let _ = try dbInstance.queue.write{ db in
                try db.execute(sql: "DELETE FROM room_message WHERE roomid IN (SELECT id FROM room WHERE docid = ?)", arguments: [documentID])
                try DocumentModel.filter(Column("id") == documentID ).deleteAll(db)
                try RoomModel.filter(Column("docid") == documentID).deleteAll(db)
            }
        } catch {
            log.error("[documentService] cleanup local document \(documentID) failed \(error)")
        }
    }
    
    func ingestDocument(entryId: Int64){
        var requset = Api_V1_TriggerWorkflowRequest()
        requset.workflowID = "buildin.ingest"
        requset.target.entryID = entryId
        
        do {
            let call = clientSet!.workflow.triggerWorkflow(requset, callOptions: nil)
            let _ = try call.response.wait()
        } catch {
            log.error("trigger workflow failed \(error)")
            return
        }
    }
}
