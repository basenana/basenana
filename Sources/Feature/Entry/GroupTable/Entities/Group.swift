//
//  EntryGroup.swift
//  Entry
//
//  Created by Hypo on 2024/11/19.
//
import Foundation
import Domain

struct UnknownGroup: EntryGroup {
    static public var shared = UnknownGroup()
    
    var id: Int64 = -1
    var groupName: String = "Unknown"
    var parentID: Int64 = -1
    var children: [any EntryGroup]? = nil
}

struct GroupCreate {
    var groupType: GroupType = .standard
    var feed: String = ""
    var siteName: String = ""
    var siteURL: String = ""
    var feedFileType: String = "webarchive"
}


enum GroupType: Identifiable {
    case standard
    case feed
    case dynamic
    
    var id: String {
        get {
            switch self {
            case .standard:
                return "group_standard"
            case .feed:
                return "group_feed"
            case .dynamic:
                return "group_dynamic"
            }
        }
    }
}


class NewGroupRequest {
    var parent: Int64
    var groupType: GroupType
    
    init(parent: Int64, groupType: GroupType) {
        self.parent = parent
        self.groupType = groupType
    }
}

