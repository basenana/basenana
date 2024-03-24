//
//  GroupModel.swift
//  basenana
//
//  Created by Hypo on 2024/3/23.
//

import Foundation

var GroupRoot: GroupModel = GroupModel(groupID: rootEntryID, groupName: "root")

@Observable
class GroupModel: Identifiable {
    var groupID: Int64
    var groupName: String
    var children: [GroupModel]? = nil
    
    init(groupID: Int64, groupName: String) {
        self.groupID = groupID
        self.groupName = groupName
    }
}
