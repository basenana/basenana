//
//  EntryService.swift
//  basenana
//
//  Created by Hypo on 2024/3/7.
//

import Foundation
import SwiftData
import SwiftUI
import GRPC
import GRDB

let entryService = EntryService()

class EntryService {
    
    func quickInbox(urlStr: String, filename: String, fileType: String, isClusterFree:Bool) {
        if clientSet == nil{
            log.error("[entryService] unauthenticated")
            return
        }
        
        var request = Api_V1_QuickInboxRequest()
        request.url = urlStr
        request.filename = filename
        request.fileType = .webArchiveFile
        request.clutterFree = isClusterFree
        let call = clientSet!.inbox.quickInbox(request, callOptions: CallOptions(timeLimit: .timeout(.seconds(10))))
        
        do {
            let response = try call.response.wait()
            log.debug("[entryService] new entey inboxed \(response.entryID)")
            try syncService.rewriteEntry(entryId: response.entryID)
        } catch {
            log.error("[entryService] entey inbox failed \(error)")
        }
    }
    
    func getEntry(entryID: Int64) -> EntryModel? {
        do {
            let data: EntryModel? = try dbInstance.queue.read{ db in
                try EntryModel.all().filter(Column("id") == entryID).fetchOne(db)
                
            }
            return data
        } catch {
            return nil
        }
    }
    
    func getRoot() -> EntryModel? {
        var req = Api_V1_FindEntryDetailRequest()
        req.root = true
        
        let call = clientSet!.entries.findEntryDetail(req, callOptions: CallOptions(timeLimit: .timeout(.seconds(10))))
        
        do {
            let response = try call.response.wait()
            return getEntry(entryID: response.entry.id)
        } catch {
            log.error("[entryService] get root entry failed \(error)")
        }
        
        return nil
    }
    
    func getInbox() -> EntryModel? {
        return findChildren(parentID: 1, chName: ".inbox")
    }
        

    func findChildren(parentID: Int64, chName: String) -> EntryModel? {
        var req = Api_V1_FindEntryDetailRequest()
        req.parentID = parentID
        req.name = chName
        
        let call = clientSet!.entries.findEntryDetail(req, callOptions: CallOptions(timeLimit: .timeout(.seconds(10))))
        do {
            let response = try call.response.wait()
            log.info(response)
            return getEntry(entryID: response.entry.id)
        } catch {
            log.error("[entryService] get root entry failed \(error)")
        }
        
        return nil
    }

    func listChildren(parentEntryID: Int64) -> [EntryModel]{
        var realParentID: Int64
        switch parentEntryID {
        case inboxEntryID:
            realParentID = (getInbox()?.id!) ?? -1
        default:
            realParentID = parentEntryID
        }
        
        if realParentID == -1{
            log.warning("no real parent entry \(parentEntryID) find")
        }
        
        do {
            let data: [EntryModel] = try dbInstance.queue.read{ db in
                try EntryModel.all().filter(Column("parent") == realParentID).fetchAll(db)
                
            }
            return data
        } catch {
            return []
        }
    }
    
    func saveLocalEntry(entry: EntryModel) {
        var newEn = entry
        do {
            let _ = try dbInstance.queue.write{ db in
                try newEn.save(db)
            }
        } catch {
            log.error("[entryService] create local entry failed \(error)")
        }
        log.debug("[entryService] created new local entry \(newEn.id ?? -1)")
    }
    
    func cleanupLocalEntry(entryID: Int64) {
        log.debug("[entryService] cleanup local entry \(entryID)")
        do {
            let _ = try dbInstance.queue.write{ db in
                try EntryModel.filter(Column("id") == entryID).deleteAll(db)
                try DocumentModel.filter(Column("oid") == entryID).deleteAll(db)
                try RoomModel.filter(Column("oid") == entryID).deleteAll(db)
                // todo delete room message also
            }
        } catch {
            log.error("[entryService] cleanup local entry \(entryID) failed \(error)")
        }
    }
}

