//
//  Entry.swift
//  basenana
//
//  Created by Hypo on 2024/2/29.
//

import Foundation


struct EntryInfo {
    var id: Int64
    var name: String
    var kind: String
    var createdAt: Date
    var changedAt: Date
    var modifiedAt: Date
    var accessAt: Date
}


struct EntryDetail {}


struct GroupNode {
    var entry: EntryInfo
    var subGroups: [GroupNode]
}
