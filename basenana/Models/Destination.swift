//
//  Destination.swift
//  basenana
//
//  Created by Hypo on 2024/6/19.
//

import Foundation

enum DocumentPrespective {
    case unread
    case marked
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
