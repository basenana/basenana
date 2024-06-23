//
//  Helper.swift
//  basenana
//
//  Created by Hypo on 2024/6/20.
//

import Foundation


func paresGroupTreeChild(root: RootGroupModel, group: Api_V1_GetGroupTreeResponse.GroupEntry) -> GroupModel{
    let gvm = GroupModel(parentID: group.entry.parentID, groupID: group.entry.id, groupName: group.entry.name)
    root.allGroups[gvm.groupID] = gvm
    if !group.children.isEmpty{
        gvm.children = []
        for grp in group.children {
            gvm.children?.append(paresGroupTreeChild(root: root, group: grp))
        }
    }
    return gvm
}
