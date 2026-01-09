//
//  Destination.swift
//
//
//  Created by Hypo on 2024/9/14.
//

import Foundation


public enum DocumentPrespective: String, CaseIterable, Identifiable {
    case unread
    case marked

    public var id: String { rawValue }

    public var Title: String {
        switch self {
        case .unread:
            return "Unread"
        case .marked:
            return "Marked"
        }
    }
}


public enum Destination: Identifiable, Hashable {

    case listDocuments(prespective: DocumentPrespective)
    case readDocument(uri: String)
    case groupList(groupUri: String)
    case workflowDashboard
    case workflowDetail(workflow: String)
    case fridayChat
    case searchDocuments

    public var id: String {
        switch self {
        case .listDocuments(prespective: let prespective):
            return "listDocument_\(prespective)"
        case .readDocument(uri: let uri):
            return "readDocument_\(uri)"
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
