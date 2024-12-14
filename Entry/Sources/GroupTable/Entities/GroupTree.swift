//
//  GroupTree.swift
//  AppState
//
//  Created by Hypo on 2024/9/21.
//

import os
import SwiftUI
import Entities


@Observable
class GroupTree {
    static var shared = GroupTree()
    
    var children: [GroupLeaf]? = []
    var allGroups: [Int64: GroupLeaf] = [:]
    
    var root: Entities.Group = UnknownGroup.shared
    var inbox: Entities.Group = UnknownGroup.shared
    
    private static let logger = Logger(
            subsystem: Bundle.main.bundleIdentifier!,
            category: String(describing: InboxViewModel.self)
        )

    private init() {}

    func reset(root: Entities.Group) {
        self.root = root
        
        children = []
        allGroups = [:]
        
        guard root.children != nil else {
            return
        }
        
        for grp in root.children! {
            children!.append(paresGroupTreeChild(group: grp))
        }
        
        Self.logger.info("reset group tree root=\(root.id)")
    }
    
    func paresGroupTreeChild(group: Entities.Group) -> GroupLeaf {
        let gvl = GroupLeaf(group: group)
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
    
    func getGroup(groupID: Int64) -> GroupLeaf? {
        return allGroups[groupID]
    }

    func changeParent(groupID: Int64, newParentID: Int64) {
        if let leaf = self.allGroups[groupID] {
            if leaf.parentID == newParentID {
                return
            }
            if let newParent = self.allGroups[newParentID]{
                for exist in newParent.children ?? [] {
                    if exist.groupName == leaf.groupName {
                        return
                    }
                }
            }
            if isInLoop(groupID: groupID, newParentID: newParentID) {
                return
            }
            self.removeChildGroup(parentID: leaf.parentID, childID: leaf.id)
            self.addChildGroup(parentID: newParentID, child: leaf.group, grandChildren: leaf.children)
            return
        }
        return
    }
    
    func addChildGroup(parentID: Int64, child: Entities.Group, grandChildren: [GroupLeaf]?){
        let newGroup = GroupLeaf(group: child)
        if grandChildren != nil{
            newGroup.children = grandChildren
        }
        
        if let parent = self.allGroups[parentID]{
            if parent.children == nil{
                parent.children = [newGroup]
                return
            }
            
            for ch in parent.children! {
                if ch.id == child.id {
                    ch.group = child
                    ch.children = grandChildren
                    return
                }
            }
            
            parent.children!.append(newGroup)
            self.allGroups[child.id] = newGroup
        }else {
            if children == nil {
                children = []
            }
            allGroups[newGroup.id] = newGroup
            children?.append(newGroup)
        }
        
    }
    
    func removeChildGroup(parentID: Int64, childID: Int64){
        guard let _ = self.allGroups[childID] else {
            Self.logger.info("[removeChildGroup] delete \(parentID)/\(childID) but child not found")
            return
        }
        
        if let parent = self.allGroups[parentID]{
            if parent.children == nil{
                Self.logger.info("[removeChildGroup] delete \(parentID)/\(childID) parent has not child")
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


@Observable
class GroupLeaf: Identifiable, Hashable {
    var id: Int64 {
        group.id
    }
    var groupName: String {
        group.groupName
    }
    var parentID: Int64 {
        group.parentID
    }
    
    
    var group: Entities.Group
    var children: [GroupLeaf]?

    init(group: Entities.Group, children: [GroupLeaf]? = nil) {
        self.group = group
        self.children = children
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(groupName)
    }
    
    static func == (lhs: GroupLeaf, rhs: GroupLeaf) -> Bool {
        return lhs.id == rhs.id
    }
}


class TreeUpdate {
    var oldLeaf: GroupLeaf
    var newLeaf: GroupLeaf?
    
    init(oldLeaf: GroupLeaf, newLeaf: GroupLeaf? = nil) {
        self.oldLeaf = oldLeaf
        self.newLeaf = newLeaf
    }
}
