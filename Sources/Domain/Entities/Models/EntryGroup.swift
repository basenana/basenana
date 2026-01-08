//
//  EntryGroup.swift
//  
//
//  Created by Hypo on 2024/9/13.
//

import Foundation


public protocol EntryGroup {
    var id: Int64 { get }
    var groupName: String { get }
    var parentID: Int64 { get }
    var children: [EntryGroup]? { get }
}
