//
//  SyncService.swift
//  basenana
//
//  Created by Hypo on 2024/4/14.
//

import Foundation
import GRPC
import GRDB
import BackgroundTasks

let syncService = SyncService()
let deviceUUID = syncService.deviceID()

@Observable
class SyncService {
    public var isSyncing: Bool = false
    private var queue = DispatchQueue(label: "org.basenana.sync")
    
    func deviceID() -> String {
        var deviceInfo: ConfigModel?
        do {
            try dbInstance.queue.read{ db in
                deviceInfo = try ConfigModel.filter(Column("name") == "org.basenana.device.uuid").fetchOne(db)
            }
        } catch {
            log.error("[syncService] query device config failed \(error)")
        }
        
        if deviceInfo != nil{
            return deviceInfo!.value
        }
        
        deviceInfo = ConfigModel(id: nil, name: "org.basenana.device.uuid", value: UUID().uuidString, changedAt: Date())
        do {
            try dbInstance.queue.write{ db in
                try deviceInfo?.save(db)
            }
            return deviceInfo!.value
        } catch {
            log.error("[syncService] init device config failed \(error)")
        }
        return "unknown"
    }
    
    func resyncBackground() {
        if isSyncing {
            return
        }
        
        isSyncing = true
        queue.async {
            self.resync()
        }
    }
    
    private func resync() {
        if clientSet == nil{
            log.error("[syncService] unauthenticated")
            return
        }
        
        isSyncing = true
        log.info("[syncService] start resync")
        defer {
            isSyncing = false
            log.info("[syncService] resync finish")
        }
        
        var syncedSqe: ConfigModel?
        do {
            try dbInstance.queue.read{ db in
                syncedSqe = try ConfigModel.filter(Column("name") == "org.basenana.sync.sequence").fetchOne(db)
            }
        } catch {
            log.error("[syncService] query sync sequence failed \(error)")
        }
        
        if syncedSqe == nil{
            syncedSqe = ConfigModel(id: nil, name: "org.basenana.sync.sequence", value: "0", changedAt: Date())
        }
        
        let syncedSeqNum = Int64(syncedSqe!.value) ?? 0
        var needRelist: Bool = syncedSeqNum == 0
        var needSyncSeq: Int64
        
        var request = Api_V1_GetLatestSequenceRequest()
        request.startSequence = syncedSeqNum
        let option = CallOptions(timeLimit: .timeout(.seconds(5)), eventLoopPreference: .indifferent)
        let unaryCall = clientSet!.notify.getLatestSequence(request, callOptions: option)
        do {
            let response = try unaryCall.response.wait()
            if response.needRelist {
                needRelist = true
            }
            needRelist = response.needRelist
            needSyncSeq = response.sequence
        } catch {
            log.error("[syncService] get latest sequence failed \(error)")
            return
        }
        
        log.debug("[syncService] current commited \(syncedSeqNum), peer sequence \(needSyncSeq)")
        if !needRelist && syncedSeqNum == needSyncSeq{
            // nothing need todo
            return
        }
        
        do {
            if needRelist {
                let syncedStartAt = Date()
                try self.relist(parentID: 1)
                try self.cleanOutmodedData(before: syncedStartAt)
            }else{
                needSyncSeq = try self.syncUncommitedEvent(start: syncedSeqNum)
            }
        } catch {
            log.error("[syncService] sync entris failed \(error)")
            return
        }
        
        do {
            syncedSqe?.value = "\(needSyncSeq)"
            syncedSqe?.changedAt = Date()
            try dbInstance.queue.write{ db in
                try syncedSqe?.save(db)
            }
            
            var request = Api_V1_CommitSyncedEventRequest()
            request.deviceID = deviceUUID
            request.sequence = needSyncSeq
            
            let call = clientSet!.notify.commitSyncedEvent(request, callOptions: nil)
            let _ = try call.response.wait()
            log.info("[syncService] commit synced event to \(needSyncSeq)")
            
        } catch{
            log.error("[syncService] writeback sync config failed \(error)")
        }
        
        groupService.initGroupTree()
    }
    
    private func relist(parentID: Int64) throws {
        log.info("[syncService] relist entry \(parentID) children")
        
        var request = Api_V1_ListGroupChildrenRequest()
        request.parentID = parentID
        let call = clientSet!.entries.listGroupChildren(request, callOptions: nil)
        
        var response: Api_V1_ListGroupChildrenResponse
        do {
            response = try call.response.wait()
        } catch {
            log.error("[syncService] list root children failed \(error)")
            throw error
        }
        
        for en in response.entries{
            try self.rewriteEntry(entryId: en.id)
            
            if en.isGroup || en.kind == "group"{
                try self.relist(parentID: en.id)
            }
        }
        
        log.info("[syncService] relist entry \(parentID) documents")
        
        var doc_request = Api_V1_ListDocumentsRequest()
        doc_request.parentID = parentID
        let doc_call = clientSet!.document.listDocuments(doc_request, callOptions: nil)
        
        var doc_response: Api_V1_ListDocumentsResponse
        do {
            doc_response = try doc_call.response.wait()
        } catch {
            log.error("[syncService] list document failed \(error)")
            throw error
        }
        
        for en in doc_response.documents {
            try self.rewriteDocument(documentId: en.id)
        }
    }
    
    private func syncUncommitedEvent(start: Int64) throws -> Int64 {
        log.info("[syncService] sync evnet start from \(start)")
        var request = Api_V1_ListUnSyncedEventRequest()
        request.startSequence = start
        let call = clientSet!.notify.listUnSyncedEvent(request, callOptions: nil)
        
        var commitedSeq = start
        do {
            let response = try call.response.wait()
            for evt in response.events {
                log.info(evt)
                do {
                    switch evt.refType{
                    case "document":
                        if evt.type == "destroy"{
                            documentService.cleanupLocalDocument(documentID: evt.refID)
                        }else{
                            try self.rewriteDocument(documentId: evt.refID)
                        }
                    case "entry":
                        if evt.type == "destroy"{
                            entryService.cleanupLocalEntry(entryID: evt.refID)
                        }else{
                            try self.rewriteEntry(entryId: evt.refID)
                        }
                    default:
                        log.error("[syncService] unknown event type \(evt.refType)")
                    }
                } catch {
                    log.error("[syncService] handle event \(evt.id) failed \(error)")
                    throw error
                }
                
                commitedSeq = evt.sequence
            }
        } catch{
            log.error("[syncService] list unsynced event failed \(error)")
            throw error
        }
        
        return commitedSeq
    }
    
    func rewriteEntry(entryId: Int64) throws {
        var request = Api_V1_GetEntryDetailRequest()
        request.entryID = entryId
        let call = clientSet!.entries.getEntryDetail(request, callOptions: nil)
        
        do {
            let response = try call.response.wait()
            let en = response.entry
            
            entryService.saveLocalEntry(entry: EntryModel(
                id: entryId, name: en.name, aliases: en.aliases, parent: en.parent.id,
                kind: en.kind, isGroup: en.isGroup, size: en.size, version: en.version,
                namespace: en.namespace, storage: en.storage,
                uid: en.access.uid, gid: en.access.gid, permissions: en.access.permissions,
                createdAt: en.changedAt.date, changedAt: en.changedAt.date, modifiedAt: en.modifiedAt.date, accessAt: en.accessAt.date, syncAt: Date()))
        } catch{
            log.error("[syncService] get entry detail failed \(error)")
            throw error
        }
    }
    
    func rewriteDocument(documentId: Int64) throws {
        var request = Api_V1_GetDocumentDetailRequest()
        request.documentID = documentId
        let call = clientSet!.document.getDocumentDetail(request, callOptions: nil)
        
        do {
            let response = try call.response.wait()
            let doc = response.document
            
            documentService.saveDocument(doc: DocumentModel(
                id: doc.id, oid: doc.entryID, name: doc.name, parentEntry: doc.parentEntryID, source: doc.source,
                marked: doc.marked, unread: doc.unread, keyWords: doc.keyWords, content: doc.htmlContent, summary: doc.summary,
                createdAt: doc.createdAt.date, changedAt: doc.changedAt.date, syncAt: Date()))
        } catch{
            log.error("[syncService] get document detail failed \(error)")
            throw error
        }
    }
    
    private func cleanOutmodedData(before: Date) throws {
        var entryList: [EntryModel] = []
        var docList: [DocumentModel] = []
        do {
            try dbInstance.queue.read{ db in
                entryList = try EntryModel.filter(Column("syncAt") < before).fetchAll(db)
                docList = try DocumentModel.filter(Column("syncAt") < before).fetchAll(db)
            }
        } catch{
            log.error("[syncService] list outmoded entry/document failed \(error)")
            throw error
        }
        
        if !entryList.isEmpty{
            for en in entryList {
                entryService.cleanupLocalEntry(entryID: en.id!)
            }
        }
        
        if !docList.isEmpty{
            for doc in docList {
                documentService.cleanupLocalDocument(documentID: doc.id)
            }
        }
    }
}
