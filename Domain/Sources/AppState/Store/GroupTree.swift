//
//  GroupTree.swift
//  AppState
//
//  Created by Hypo on 2024/9/21.
//

import SwiftUI
import Entities


@available(macOS 14.0, *)
@Observable
public class GroupTree {
    public var children: [GroupLeaf]? = []
    
    var allGroups: [Int64: GroupLeaf] = [:]
    
    public init(){}
    
    public func reset(groups: [Entities.Group]) {
        children = []
        allGroups = [:]
        
        for grp in groups {
            if grp.children == nil {
                continue
            }
            children!.append(paresGroupTreeChild(group: grp))
        }
    }
    
    private func paresGroupTreeChild(group: Entities.Group) -> GroupLeaf {
        let gvl = GroupLeaf(id: group.id, groupName: group.groupName, parentID: group.parentID)
        allGroups[gvl.id] = gvl
        
        
        guard let children = group.children else {
            return gvl
        }
        
        if !children.isEmpty {
            gvl.children = []
            for grp in children {
                gvl.children?.append(paresGroupTreeChild(group: grp))
            }
        }
        return gvl
    }
    
    public func changeParent(groupID: Int64, newParentID: Int64) {
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
            self.removeChildGroup(parentID: group.parentID, childID: group.id)
            self.addChildGroup(parentID: newParentID, childID: group.id, childName: group.groupName, grandChildren: group.children)
            return
        }
        return
    }
    
    public func addChildGroup(parentID: Int64, childID: Int64, childName: String, grandChildren: [GroupLeaf]?){
        let newGroup = GroupLeaf(id: childID, groupName: childName, parentID: parentID)
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
            allGroups[newGroup.id] = newGroup
            children?.append(newGroup)
        }
        
    }
    
    public func removeChildGroup(parentID: Int64, childID: Int64){
        guard let _ = self.allGroups[childID] else {
            print("[removeChildGroup] delete \(parentID)/\(childID) but child not found")
            return
        }
        
        if let parent = self.allGroups[parentID]{
            if parent.children == nil{
                print("[removeChildGroup] delete \(parentID)/\(childID) parent has not child")
                return
            }
            
            parent.children = parent.children!.filter { $0.id != childID }
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


public class GroupLeaf: Identifiable, Hashable {
    public var id: Int64
    public var groupName: String
    public var parentID: Int64
    public var children: [GroupLeaf]?
    
    public init(id: Int64, groupName: String, parentID: Int64, children: [GroupLeaf]? = nil) {
        self.id = id
        self.groupName = groupName
        self.parentID = parentID
        self.children = children
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(groupName)
    }
    
    public static func == (lhs: GroupLeaf, rhs: GroupLeaf) -> Bool {
        return lhs.id == rhs.id
    }
}
