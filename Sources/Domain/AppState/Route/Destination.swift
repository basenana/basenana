//
//  Destination.swift
//
//
//  Created by Hypo on 2024/9/14.
//

import Foundation



public enum Destination: Identifiable, Hashable {

    case listDocuments(prespective: DocumentPrespective)
    case readDocument(document: Int64)
    case groupList(groupUri: String)
    case workflowDashboard
    case workflowDetail(workflow: String)
    case fridayChat
    case searchDocuments

    public var id: String {
        switch self {
        case .listDocuments(prespective: let prespective):
            return "listDocument_\(prespective)"
        case .readDocument(document: let document):
            return "readDocument_\(document)"
        case .groupList(groupUri: let groupUri):
            return "groupList_\(groupUri)"
        case .workflowDashboard:
            return "workflowDashboard"
        case .workflowDetail(workflow: let workflow):
            return "workflowDetail_\(workflow)"
        case .fridayChat:
            return "fridayChat"
        case .searchDocuments:
            return "searchDocument"
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

extension EntryGroup {
    var destination: Destination {
        return .groupList(groupUri: self.uri)
    }
}
