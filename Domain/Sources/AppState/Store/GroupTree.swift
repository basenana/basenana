//
//  GroupTree.swift
//  AppState
//
//  Created by Hypo on 2024/9/21.
//

import Entities


public class GroupTree {
    public var children: [GroupLeaf]? = nil
    var allGroups: [Int64: GroupLeaf] = [:]
    
    public func reset(groups: [Entities.Group]) {
        
    }
}


public class GroupLeaf: Identifiable {
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
    
    public static func == (lhs: GroupLeaf, rhs: GroupLeaf) -> Bool {
        return lhs.id == rhs.id
    }
}
