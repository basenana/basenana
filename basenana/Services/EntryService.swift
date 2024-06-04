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
    
    @AppStorage("org.basenana.nanafs.rootId", store: UserDefaults.standard)
    private var rootId: Int = 0
    
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
        let call = clientSet!.inbox.quickInbox(request, callOptions: defaultCallOptions)
        
        do {
            let response = try call.response.wait()
            log.debug("[entryService] new entey inboxed \(response.entryID)")
        } catch {
            log.error("[entryService] entey inbox failed \(error)")
        }
    }
    
    func createGroup(groupName: String, parentId: Int64) {
        var request = Api_V1_CreateEntryRequest()
        request.kind = "group"
        request.name = groupName
        request.parentID = parentId
        
        let call = clientSet?.entries.createEntry(request, callOptions: defaultCallOptions)
        
        do {
            let _ = try call?.response.wait()
            GroupRoot.updateAt = Date()
        } catch {
            log.error("[entryService] create group failed \(error)")
        }
    }
    
    func deleteEntry(entryId: Int64) {
        var request = Api_V1_DeleteEntryRequest()
        request.entryID = entryId
        
        let call = clientSet?.entries.deleteEntry(request, callOptions: defaultCallOptions)
        
        do {
            let _ = try call?.response.wait()
            GroupRoot.updateAt = Date()
        } catch {
            log.error("[entryService] delete entry failed \(error)")
        }
    }

    func getEntry(entryID: Int64) -> EntryDetailModel? {
        do {
            var request = Api_V1_GetEntryDetailRequest()
            request.entryID = entryID
            let call = clientSet!.entries.getEntryDetail(request, callOptions: defaultCallOptions)
            let response = try call.response.wait()
            return entryDetail2Model(en: response.entry, properties: response.properties)
        } catch {
            log.error("[EntryService] sync entris failed \(error)")
            return nil
        }
    }
    
    func getRoot() -> EntryDetailModel? {
        var req = Api_V1_FindEntryDetailRequest()
        req.root = true
        
        let call = clientSet!.entries.findEntryDetail(req, callOptions: defaultCallOptions)
        
        do {
            let response = try call.response.wait()
            return entryDetail2Model(en: response.entry, properties: response.properties)
        } catch {
            log.error("[entryService] get root entry failed \(error)")
        }
        
        return nil
    }
    
    func getInbox() -> EntryDetailModel? {
        let rootEn = getRoot()
        return findChildren(parentID: rootEn!.id, chName: ".inbox")
    }

    func findChildren(parentID: Int64, chName: String) -> EntryDetailModel? {
        var req = Api_V1_FindEntryDetailRequest()
        req.parentID = parentID
        req.name = chName
        
        let call = clientSet!.entries.findEntryDetail(req, callOptions: defaultCallOptions)
        do {
            let response = try call.response.wait()
            return entryDetail2Model(en: response.entry, properties: response.properties)
        } catch {
            log.error("[entryService] find children \(chName) of \(parentID) failed \(error)")
        }
        
        return nil
    }
    
    func listChildren(parentEntryID: Int64, filter: EntryFilter? = nil, order: EntryOrder? = nil, pages: Pagination? = nil) -> [EntryInfoModel]{
        var realParentID: Int64
        switch parentEntryID {
        case inboxEntryID:
            realParentID = (getInbox()?.id) ?? -1
        default:
            realParentID = parentEntryID
        }
        
        if realParentID == -1{
            log.warning("no real parent entry \(parentEntryID) find")
        }
        
        do {
            var req = Api_V1_ListGroupChildrenRequest()
            req.parentID = realParentID
            if let ps = pages {
                req.pagination = Api_V1_Pagination()
                req.pagination.page = ps.page
                req.pagination.pageSize = ps.pageSize
            }
            
            if let f = filter {
                req.filter = Api_V1_EntryFilter()
                if f.isGroup == true {
                    req.filter.isGroup = Api_V1_EntryFilter.GroupFilter.group
                }
            }
            
            if let o = order {
                switch o.order {
                case EnOrder.createAt:
                    req.order = Api_V1_ListGroupChildrenRequest.EntryOrder.createdAt
                case .modifiedAt:
                    req.order = Api_V1_ListGroupChildrenRequest.EntryOrder.modifiedAt
                case .name:
                    req.order = Api_V1_ListGroupChildrenRequest.EntryOrder.name
                case .kind:
                    req.order = Api_V1_ListGroupChildrenRequest.EntryOrder.kind
                case .size:
                    req.order = Api_V1_ListGroupChildrenRequest.EntryOrder.size
                }
                if o.desc == true {
                    req.orderDesc = true
                }

            }
            
            let call = clientSet!.entries.listGroupChildren(req, callOptions: defaultCallOptions)
            let response = try call.response.wait()
            var entries: [EntryInfoModel]=[]
            for entry in response.entries {
                if !entry.name.hasPrefix(".") { entries.append(entryInfo2Model(en: entry)) }
            }
            
            return entries
        } catch {
            return []
        }
    }
    
    func entryDetail2Model(en: Api_V1_EntryDetail, properties: [Api_V1_Property]) -> EntryDetailModel{
        var enProperties: [EntryPropertyModel]=[]
        for property in properties {
            enProperties.append(EntryPropertyModel(key: property.key, value: property.value, encoded: property.encoded))
        }
        return EntryDetailModel(
            id: en.id, name: en.name, aliases: en.aliases, parent: en.parent.id,
            kind: en.kind, isGroup: en.isGroup, size: en.size, version: en.version,
            namespace: en.namespace, storage: en.storage,
            uid: en.access.uid, gid: en.access.gid, permissions: en.access.permissions,
            createdAt: en.changedAt.date, changedAt: en.changedAt.date, modifiedAt: en.modifiedAt.date, accessAt: en.accessAt.date,
            properties: enProperties
        )
    }
    
    func entryInfo2Model(en: Api_V1_EntryInfo) -> EntryInfoModel{
        return EntryInfoModel(
            id: en.id, name: en.name, kind: en.kind, isGroup: en.isGroup, size: en.size,
            createdAt: en.changedAt.date, changedAt: en.changedAt.date, modifiedAt: en.modifiedAt.date, accessAt: en.accessAt.date
        )
    }
}

