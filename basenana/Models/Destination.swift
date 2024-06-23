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
    case readDocuments(prespective: DocumentPrespective)
    case groupList(group: GroupModel)

    var id: String {
        switch self {
        case .mainContent:
            return "mainContent"
        case .readDocuments(prespective: let prespective):
            return "readDocument_\(prespective)"
        case .groupList(group: let group):
            return "groupList_\(group.groupID)"
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
