//
//  GroupService.swift
//  basenana
//
//  Created by Hypo on 2024/3/15.
//

import Foundation
import SwiftUI
import GRPC

extension Service {
    
    func moveEntriesToGroup(entries: [Int64], groupID: Int64) throws {
        for entry in entries {
            try moveEntryToGroup(entryId: entry, groupID: groupID)
        }
    }
    
    func moveEntryToGroup(entryId: Int64, groupID: Int64) throws {
        let clientSet = try clientFactory.makeClient()
        log.info("[groupService] move \(entryId) -> \(groupID)")
        var request = Api_V1_ChangeParentRequest()
        request.entryID = entryId
        request.newParentID = groupID
        let call = clientSet.entries.changeParent(request, callOptions: defaultCallOptions)
        
        do {
            let _ = try call.response.wait()
        } catch {
            log.error("move entry \(entryId) failed \(error)")
            throw error
        }
    }
}

