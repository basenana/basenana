//
//  GroupService.swift
//  basenana
//
//  Created by Hypo on 2024/3/15.
//

import Foundation
import GRDB
import SwiftUI

let groupService = GroupService()

class GroupService {
    @AppStorage("org.basenana.nanafs.namespace", store: UserDefaults.standard)
    private var namespace: String = ""
    
    @AppStorage("org.basenana.nanafs.rootId", store: UserDefaults.standard)
    private var rootId: Int = 0
    
    func initGroupTree() {
        rootGroup()
        log.debug("[GroupService] init group tree, id: \(GroupRoot.groupID), name: \(GroupRoot.groupName)")

        var needInitGroups = [GroupRoot]
        
        while !needInitGroups.isEmpty{
            let nextGroup = needInitGroups[0]
            needInitGroups.remove(at: 0)
            let gid = nextGroup.groupID
            let children = entryService.listChildren(parentEntryID: gid, filter: EntryFilter(isGroup: true))
            
            nextGroup.children = children.compactMap{ en in
                if !en.name.starts(with: "."){
                    return GroupViewModel(groupID: en.id, groupName: en.name)
                }
                return nil
            }
            
            if nextGroup.children == nil || nextGroup.children!.isEmpty{
                nextGroup.children = nil
                continue
            }
            
            for subGroup in nextGroup.children!{
                needInitGroups.append(subGroup)
            }}
        
        GroupRoot.updateAt = Date()
    }
    
    func rootGroup() {
        if self.rootId == 0 {
            let rootEntry = entryService.getRoot()
            self.rootId = Int(rootEntry?.id ?? 0)
        }
        GroupRoot.groupID = Int64(self.rootId)
        GroupRoot.groupName = self.namespace
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
    }
    
}
