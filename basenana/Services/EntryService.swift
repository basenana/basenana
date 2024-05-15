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
    
    func getEntryProperty(entryID: Int64) -> [EntryPropertyModel] {
        do {
            let data: [EntryPropertyModel] = try dbInstance.queue.read{ db in
                try EntryPropertyModel.all().filter(Column("oid") == entryID).fetchAll(db)
            }
            return data
        } catch {
            return []
        }
    }
    
    func syncEntryProperty(entryId: Int64) throws {
        var request = Api_V1_GetEntryDetailRequest()
        request.entryID = entryId
        let call = clientSet!.entries.getEntryDetail(request, callOptions: nil)
        
        do {
            let response = try call.response.wait()
            let properties = response.properties
            
            for property in properties {
                entryService.saveLocalEntryProperty(entryProperty: EntryPropertyModel(
                    oid: entryId, key: property.key, value: property.value, encoded: property.encoded, syncAt: Date()))
            }
        } catch{
            if error.localizedDescription.contains("not found") {
                return
            }
            log.error("[entryService] sync entry property failed \(error)")
            throw error
        }
    }
    
    func listChildren(parentEntryID: Int64, orderName: EntryOrder, desc: Bool) -> [EntryModel]{
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
                let orderColumnMap = [
                    EntryOrder.modifiedAt: "modifiedAt",
                    EntryOrder.kind: "kind",
                    EntryOrder.name: "name",
                    EntryOrder.size: "size"
                ]
                var en = EntryModel.all().filter(Column("parent") == realParentID)
                if let orderColumnName = orderColumnMap[orderName] {
                    log.debug("list children column name: \(orderColumnName), desc: \(desc)")
                    en = desc ? en.order(Column(orderColumnName).desc) : en.order(Column(orderColumnName))
                }
                return try en.fetchAll(db)
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
    
    func saveLocalEntryProperty(entryProperty: EntryPropertyModel) {
        var newEnp = entryProperty
        var crtEnp: EntryPropertyModel?
        do {
            let crtEnps: [EntryPropertyModel] = try dbInstance.queue.read{ db in
                try EntryPropertyModel.all().filter(Column("oid") == entryProperty.oid).fetchAll(db)
            }
            for c in crtEnps {
                if c.key == entryProperty.key {
                    crtEnp = c
                    break
                }
            }
            if let c = crtEnp {
                newEnp.id = c.id
            }
            let _ = try dbInstance.queue.write{ db in
                try newEnp.save(db)
            }
        } catch {
            log.error("[entryService] create local entry property failed \(error)")
        }
    }
    
    func cleanupLocalEntry(entryID: Int64) {
        log.debug("[entryService] cleanup local entry \(entryID)")
        do {
            let _ = try dbInstance.queue.write{ db in
                try EntryModel.filter(Column("id") == entryID).deleteAll(db)
                try EntryPropertyModel.filter(Column("oid") == entryID).deleteAll(db)
                try DocumentModel.filter(Column("oid") == entryID).deleteAll(db)
                try RoomModel.filter(Column("oid") == entryID).deleteAll(db)
                try db.execute(sql: "DELETE FROM room_message WHERE roomid IN (SELECT id FROM room WHERE oid = ?)", arguments: [entryID])
            }
        } catch {
            log.error("[entryService] cleanup local entry \(entryID) failed \(error)")
        }
    }
}

