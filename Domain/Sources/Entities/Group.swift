//
//  Group.swift
//  
//
//  Created by Hypo on 2024/9/13.
//

import Foundation


protocol Group {
    var id: Int64 { get }
    var groupName: String { get }
    var parentID: Int64 { get }
    var children: [Group]? { get }
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
