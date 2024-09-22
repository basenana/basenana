//
//  Destination.swift
//
//
//  Created by Hypo on 2024/9/14.
//

import Foundation
import Entities


public enum DocumentPrespective {
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


public enum Destination: Identifiable, Hashable {
    
    case mainContent
    case fridayChat
    case readDocuments(prespective: DocumentPrespective)
    case groupList(group: Int64)
    case workflowDashboard

    public var id: String {
        switch self {
        case .mainContent:
            return "mainContent"
        case .fridayChat:
            return "fridayChat"
        case .readDocuments(prespective: let prespective):
            return "readDocument_\(prespective)"
        case .groupList(group: let group):
            return "groupList_\(group)"
        case .workflowDashboard:
            return "workflowDashboard"
        }
    }
    
    public static func == (lhs: Destination, rhs: Destination) -> Bool {
        return lhs.id == rhs.id
    }
    
}


extension DocumentPrespective {
    var destination: Destination {
        return .readDocuments(prespective: self)
    }
}

extension Group {
    var destination: Destination {
        return .groupList(group: self.id)
    }
}
