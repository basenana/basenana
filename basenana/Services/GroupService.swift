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
                        return GroupModel(groupID: en.id!, groupName: en.name)
                    }
                    return nil
                }
            } catch {
                print("query group \(nextGroup.groupID) children failed")
            }
            
            if nextGroup.children == nil || nextGroup.children!.isEmpty{
                nextGroup.children = nil
                continue
            }
            
            for subGroup in nextGroup.children!{
                needInitGroups.append(subGroup)
            }}
    }
}
