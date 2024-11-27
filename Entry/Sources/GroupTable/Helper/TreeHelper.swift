//
//  TreeHelper.swift
//  Entry
//
//  Created by Hypo on 2024/11/26.
//

import Foundation
import Entities
import UseCaseProtocol


func createGroupAndUpdateTree(entryUsecase: EntryUseCaseProtocol, parentID: Int64, option: EntryCreate) async throws -> EntryInfo {
    guard GroupTree.shared.getGroup(groupID: parentID) != nil else {
        throw BizError.invalidArg("creatr group failed: parent \(parentID) not exist")
    }
    
    let newGroup = try await entryUsecase.createGroups(parent: parentID, option: option)
    
    // insert to the tree
    GroupTree.shared.addChildGroup(parentID: parentID, child: newGroup.toGroup()!, grandChildren: [])
    return newGroup
}

