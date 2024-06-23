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
    
    func changeParent(groupID: Int64, newParentID: Int64) {
        if let group = self.allGroups[groupID] {
            if group.parentID == newParentID {
                return
            }
            if let newParent = self.allGroups[newParentID]{
                for exist in newParent.children ?? [] {
                    if exist.groupName == group.groupName {
                        return
                    }
                }
            }
            if isInLoop(groupID: groupID, newParentID: newParentID) {
                return
            }
            self.removeChildGroup(parentID: group.parentID, childID: group.groupID)
            self.addChildGroup(parentID: newParentID, childID: group.groupID, childName: group.groupName, grandChildren: group.children)
            return
        }
        return
    }
    
    func addChildGroup(parentID: Int64, childID: Int64, childName: String, grandChildren: [GroupModel]?){
        let newGroup = GroupModel(parentID: parentID, groupID: childID, groupName: childName)
        if grandChildren != nil{
            newGroup.children = grandChildren
        }
        
        if let parent = self.allGroups[parentID]{
            if parent.children == nil{
                parent.children = [newGroup]
                return
            }
            
            for ch in parent.children! {
                if ch.id == childID {
                    ch.groupName = childName
                    return
                }
            }
            
            parent.children!.append(newGroup)
            self.allGroups[childID] = newGroup
        }else {
            if children == nil {
                children = []
            }
            allGroups[newGroup.groupID] = newGroup
            children?.append(newGroup)
        }
        
    }
    
    func removeChildGroup(parentID: Int64, childID: Int64){
        guard let _ = self.allGroups[childID] else {
            log.info("delete \(parentID)/\(childID) but child not found")
            return
        }
        
        if let parent = self.allGroups[parentID]{
            if parent.children == nil{
                log.info("delete \(parentID)/\(childID) parent has not child")
                return
            }
            
            parent.children = parent.children!.filter { $0.groupID != childID }
            if parent.children?.isEmpty ?? false {
                parent.children = nil
            }
            self.allGroups[childID] = nil
        }
    }
    
    func isInLoop(groupID: Int64, newParentID: Int64) -> Bool {
        var nextParentID: Int64 = newParentID
        while let parent = allGroups[nextParentID] {
            if parent.id == groupID {
                return true
            }
            nextParentID = parent.parentID
        }
        return false
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

