//
//  GroupModel.swift
//  basenana
//
//  Created by Hypo on 2024/6/19.
//

import Foundation


class RootGroupModel {
    var children: [GroupModel]? = nil
    var allGroups: [Int64: GroupModel] = [:]
    
    func changeParent(groupID: Int64, newParentID: Int64){
        if let group = self.allGroups[groupID] {
            self.removeChildGroup(parentID: group.parentID, childID: group.groupID)
            self.addChildGroup(parentID: newParentID, childID: group.groupID, childName: group.groupName)
        }
    }
    
    func addChildGroup(parentID: Int64, childID: Int64, childName: String){
        if let parent = self.allGroups[parentID]{
            if parent.children == nil{
                parent.children = [GroupModel(parentID: parentID, groupID: childID, groupName: childName)]
                return
            }
            
            for ch in parent.children! {
                if ch.id == childID {
                    ch.groupName = childName
                    return
                }
            }
            
            let grp = GroupModel(parentID: parentID, groupID: childID, groupName: childName)
            parent.children!.append(grp)
            self.allGroups[childID] = grp
        }
    }
    
    func removeChildGroup(parentID: Int64, childID: Int64){
        guard let _ = self.allGroups[childID] else {
            return
        }
        
        if let parent = self.allGroups[parentID]{
            if parent.children == nil{
                return
            }
            
            parent.children = parent.children!.filter { $0.groupID != childID }
            if parent.children?.isEmpty ?? false {
                parent.children = nil
            }
            self.allGroups[childID] = nil
        }
    }
}


class GroupModel: Identifiable, Hashable {
    var groupID: Int64
    var groupName: String
    var parentID: Int64
    var children: [GroupModel]? = nil
    
    
    init(parentID: Int64, groupID: Int64, groupName: String) {
        self.groupID = groupID
        self.groupName = groupName
        self.parentID = parentID
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(groupID)
        hasher.combine(groupName)
    }
    
    var id: Int64{
        return self.groupID
    }
    
    static func == (lhs: GroupModel, rhs: GroupModel) -> Bool {
        return lhs.groupID == rhs.groupID
    }
}

