//
//  Destination.swift
//
//
//  Created by Hypo on 2024/9/14.
//

import Foundation
import Entities


public enum Destination: Identifiable, Hashable {
    
    case listDocuments(prespective: DocumentPrespective)
    case readDocument(document: Int64)
    case groupList(group: Int64)
    case workflowDashboard
    case workflowDetail(workflow: String)
    case fridayChat

    public var id: String {
        switch self {
        case .listDocuments(prespective: let prespective):
            return "listDocument_\(prespective)"
        case .readDocument(document: let document):
            return "readDocument_\(document)"
        case .groupList(group: let group):
            return "groupList_\(group)"
        case .workflowDashboard:
            return "workflowDashboard"
        case .workflowDetail(workflow: let workflow):
            return "workflowDetail_\(workflow)"
        case .fridayChat:
            return "fridayChat"
        }
    }
    
    public static func == (lhs: Destination, rhs: Destination) -> Bool {
        return lhs.id == rhs.id
    }
    
}


extension DocumentPrespective {
    var destination: Destination {
        return .listDocuments(prespective: self)
    }
}

extension Group {
    var destination: Destination {
        return .groupList(group: self.id)
    }
}
