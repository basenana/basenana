//
//  GroupService.swift
//  basenana
//
//  Created by Hypo on 2024/3/15.
//

import Foundation
import SwiftUI
import GRPC
import GRDB

let groupService = GroupService()

class GroupService {
    @AppStorage("org.basenana.nanafs.namespace", store: UserDefaults.standard)
    private var namespace: String = ""
    
    @AppStorage("org.basenana.nanafs.rootId", store: UserDefaults.standard)
    private var rootId: Int = 0
    
    func initGroupTree() {
        log.debug("[groupService] start init group tree, id: \(GroupRoot.groupID), name: \(GroupRoot.groupName)")
        
        let req = Api_V1_GetGroupTreeRequest()
        let call = clientSet!.entries.groupTree(req, callOptions: defaultCallOptions)
        do {
            let response = try call.response.wait()
            GroupRoot.groupID = response.root.entry.id
            GroupRoot.groupName = response.root.entry.name
            GroupRoot.children = []
            for grp in response.root.children {
                GroupRoot.children?.append(buildGroupEntry(group: grp))
            }
        } catch {
            log.error("[groupService] find children failed \(error)")
            return
        }
        
        log.debug("[groupService] init group tree finish, id: \(GroupRoot.groupID), name: \(GroupRoot.groupName)")
    }
    
    func moveEntriesToGroup(entries: [Int64], groupID: Int64) {
        for entry in entries {
            moveEntryToGroup(entryId: entry, groupID: groupID)
        }
        GroupRoot.updateAt = Date()
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
        let call = clientSet!.entries.changeParent(request, callOptions: defaultCallOptions)
        
        do {
            let _ = try call.response.wait()
        } catch {
            log.error("move entry \(entryId) failed \(error)")
            return
        }
    }
    
}

func buildGroupEntry(group: Api_V1_GetGroupTreeResponse.GroupEntry) -> GroupViewModel{
    let gvm = GroupViewModel(groupID: group.entry.id, groupName: group.entry.name)
    if !group.children.isEmpty{
        gvm.children = []
        for grp in group.children {
            gvm.children?.append(buildGroupEntry(group: grp))
        }
    }
    return gvm
}
