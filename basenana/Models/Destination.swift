//
//  Destination.swift
//  basenana
//
//  Created by Hypo on 2024/6/19.
//

import Foundation

enum DocumentPrespective {
    case none
    case unread
    case marked
    
    var Title: String {
        switch self {
        case .none:
            return "Basenana"
        case .unread:
            return "Unread"
        case .marked:
            return "Marked"
        }
    }
}


enum Destination: Identifiable, Hashable, Equatable {
    
    case mainContent
    case fridayChat
    case readDocuments(prespective: DocumentPrespective)
    case groupListByID(groupID: Int64)
    case groupList(group: GroupModel)
    case workflowDashboard

    var id: String {
        switch self {
        case .mainContent:
            return "mainContent"
        case .fridayChat:
            return "fridayChat"
        case .readDocuments(prespective: let prespective):
            return "readDocument_\(prespective)"
        case .groupListByID(groupID: let group):
            return "groupListByID_\(group)"
        case .groupList(group: let group):
            return "groupList_\(group.groupID)"
        case .workflowDashboard:
            return "workflowDashboard"
        }
    }
}


extension DocumentPrespective {
    var destination: Destination {
        return .readDocuments(prespective: self)
    }
}

extension GroupModel {
    var destination: Destination {
        return .groupList(group: self)
    }
}
