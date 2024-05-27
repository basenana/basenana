//
//  GroupViewModel.swift
//  basenana
//
//  Created by Hypo on 2024/3/23.
//

import Foundation

var GroupRoot: GroupViewModel = GroupViewModel(groupID: rootEntryID, groupName: "root")

@Observable
class GroupViewModel: Identifiable, Hashable {
    var id: Int64
    var groupID: Int64
    var groupName: String
    var children: [GroupViewModel]? = nil
    var updateAt: Date? = nil
    
    init(groupID: Int64, groupName: String) {
        self.id = groupID
        self.groupID = groupID
        self.groupName = groupName
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(groupID)
        hasher.combine(groupName)
    }
    
    static func == (lhs: GroupViewModel, rhs: GroupViewModel) -> Bool {
        return lhs.groupID == rhs.groupID
    }
}
