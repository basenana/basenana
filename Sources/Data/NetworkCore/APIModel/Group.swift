//
//  GroupModel.swift
//  basenana
//
//  Created by Hypo on 2024/6/19.
//

import Foundation
import Domain
import Domain


public struct APIGroup: EntryGroup {
    public var id: Int64
    
    public var groupName: String
    
    public var parentID: Int64
    
    public var children: [any EntryGroup]?
    
    public init(id: Int64, groupName: String, parentID: Int64, children: [any EntryGroup]? = nil) {
        self.id = id
        self.groupName = groupName
        self.parentID = parentID
        self.children = children
    }
}


