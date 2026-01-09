//
//  Notify.swift
//  Document
//
//  Created by Hypo on 2024/12/7.
//

import Foundation


public extension Notification.Name {
    static let openDocument = Notification.Name(rawValue: "openDocument")
    static let updateDocumentMark = Notification.Name(rawValue: "updateDocumentMark")
    static let loadMoreDocuments = Notification.Name(rawValue: "loadMoreDocuments")
}


class UpdateDocumentMark {
    var updateRead: Bool
    var isUnread: Bool

    var updateMark: Bool
    var isMarked: Bool

    var uri: String

    init(uri: String, isUnread: Bool) {
        self.uri = uri
        self.updateRead = true
        self.isUnread = isUnread

        self.updateMark = false
        self.isMarked = false
    }

    init(uri: String, isMarked: Bool) {
        self.uri = uri
        self.updateRead = false
        self.isUnread = false

        self.updateMark = true
        self.isMarked = isMarked
    }
}
