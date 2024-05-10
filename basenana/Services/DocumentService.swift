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
    
    func listDocuments() -> [DocumentModel]{
        do {
            let data: [DocumentModel] = try dbInstance.queue.read{ db in
                try DocumentModel.filter(Column("unread") == true).order(Column("createdAt").desc).fetchAll(db)
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
    
    func readDocument(docId: Int64, unread: Bool) {
        var doc: DocumentModel?
        do {
            doc = try dbInstance.queue.read{ db in
                try DocumentModel.filter(Column("id") == docId).fetchOne(db)
            }
            
            if doc?.unread == unread {
                return
            }
            
            var request = Api_V1_UpdateDocumentRequest()
            request.document.id = docId
            request.setMark = unread ? Api_V1_UpdateDocumentRequest.DocumentMark.unread:Api_V1_UpdateDocumentRequest.DocumentMark.read
            log.debug("update request \(request) doc: \(docId) unread: \(unread)")

            let _ = clientSet?.document.updateDocument(request, callOptions: nil)
            
            doc?.unread = unread
            let _ = try dbInstance.queue.write{db in
                try doc?.save(db)
            }
        } catch {
            log.error("[documentService] set docuemnt unread \(unread) failed \(error)")
        }
        return
    }
    
    func markDocument(docId: Int64, mark: Bool) {
        var doc: DocumentModel?
        do {
            doc = try dbInstance.queue.read{ db in
                try DocumentModel.filter(Column("id") == docId).fetchOne(db)
            }
            
            if doc?.marked == mark {
                return
            }
            
            var request = Api_V1_UpdateDocumentRequest()
            request.setMark = mark ? Api_V1_UpdateDocumentRequest.DocumentMark.marked:Api_V1_UpdateDocumentRequest.DocumentMark.unmarked
            
            let _ = clientSet?.document.updateDocument(request, callOptions: nil)
            
            let _ = try dbInstance.queue.write{db in
                try doc?.save(db)
            }
        } catch {
            log.error("[documentService] set docuemnt unread \(mark) failed \(error)")
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
