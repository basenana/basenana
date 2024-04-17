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
    
    func quickInbox(urlStr: String, fileType: String, isClusterFree:Bool) {
        var request = Api_V1_QuickInboxRequest()
        request.url = urlStr
        request.fileType = .webArchiveFile
        request.clutterFree = isClusterFree
        let call = clientSet.inbox.quickInbox(request, callOptions: CallOptions(timeLimit: .timeout(.seconds(10))))
        
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
    
    func listChildren(parentEntryID: Int64) -> [EntryModel]{
        do {
            let data: [EntryModel] = try dbInstance.queue.read{ db in
                try EntryModel.all().filter(Column("parent") == parentEntryID).fetchAll(db)
                
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
                try DialogueModel.filter(Column("oid") == entryID).deleteAll(db)
            }
        } catch {
            log.error("[entryService] cleanup local entry \(entryID) failed \(error)")
        }
    }
}

