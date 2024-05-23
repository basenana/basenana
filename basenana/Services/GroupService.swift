//
//  GroupService.swift
//  basenana
//
//  Created by Hypo on 2024/3/15.
//

import Foundation
import SwiftData
import GRDB

let groupService = GroupService()

class GroupService {
    
    func initGroupTree() {
        log.debug("[GroupService] init group tree, id: \(GroupRoot.groupID), name: \(GroupRoot.groupName)")
        genRootGroup()
        
        var needInitGroups = [GroupRoot]
        
        while !needInitGroups.isEmpty{
            let nextGroup = needInitGroups[0]
            needInitGroups.remove(at: 0)
            let gid = nextGroup.groupID
            do {
                let children = try dbInstance.queue.read{ db in
                    try EntryModel.filter(Column("parent") == gid && Column("isGroup") == true).fetchAll(db)
                }
                nextGroup.children = children.compactMap{ en in
                    if !en.name.starts(with: "."){
                        return GroupViewModel(groupID: en.id!, groupName: en.name)
                    }
                    return nil
                }
            } catch {
                log.error("query group \(nextGroup.groupID) children failed")
            }
            
            if nextGroup.children == nil || nextGroup.children!.isEmpty{
                nextGroup.children = nil
                continue
            }
            
            for subGroup in nextGroup.children!{
                needInitGroups.append(subGroup)
            }}
    }
    
    func genRootGroup() {
        do {
            let ns: NamespaceModel? = try dbInstance.queue.read{ db in
                try NamespaceModel.fetchOne(db)
            }
            GroupRoot = GroupViewModel(groupID: ns?.entryId ?? 1, groupName: ns?.name ?? "root")
        } catch {
            log.error("query root failed")
        }
    }
    
    func moveEntriesToGroup(entries: [Int64], groupID: Int64) {
        for entry in entries {
            moveEntryToGroup(entryId: entry, groupID: groupID)
        }
    }
    
    func moveEntryToGroup(entryId: Int64, groupID: Int64) {
        if clientSet == nil {
            log.error("move entry \(entryId) failed, client not init")
            return
        }
        
        log.info("move \(entryId) -> \(groupID)")
        var request = Api_V1_ChangeParentRequest()
        request.entryID = entryId
        request.newParentID = groupID
        let call = clientSet!.entries.changeParent(request, callOptions: nil)
        
        do {
            let _ = try call.response.wait()
        } catch {
            log.error("move entry \(entryId) failed \(error)")
            return
        }
        
        do {
            try syncService.rewriteEntry(entryId: entryId)
            try syncService.rewriteEntry(entryId: groupID)
        } catch {
            log.error("resync entry \(entryId) failed \(error)")
        }

        GroupRoot.updateAt = Date()
    }
        
}
