//
//  DocumentSection.swift
//  Document
//
//  Created by Hypo on 2024/11/23.
//

import SwiftUI
import Foundation
import Domain


@Observable
class DocumentSection: Identifiable {
    var id: String
    var documents: [DocumentItem]

    init(id: String, documents: [DocumentItem]) {
        self.id = id
        self.documents = documents
    }
}

@Observable
class DocumentItem: Identifiable, Hashable, Equatable {
    var id: String {
        get {
            return info.uri
        }
    }

    var uri: String {
        get {
            return info.uri
        }
    }

    // editable
    var isUnread: Bool
    var isMarked: Bool
    var headerImage: String {
        get {
            return info.documentHeaderImage ?? ""
        }
    }

    var info: EntryInfo
    var readable: Bool = false

    var keepLowProfile: Bool {
        return readable && !isUnread
    }

    init(info: EntryInfo) {
        self.info = info
        self.readable = false

        self.isMarked = info.documentMarked
        self.isUnread = info.documentUnread
    }

    init(info: EntryInfo, readable: Bool) {
        self.info = info
        self.readable = readable

        self.isMarked = info.documentMarked
        self.isUnread = info.documentUnread
    }

    var sectionName: String {
        if Calendar.current.isDateInToday(info.createdAt){
            return "TODAY"
        }
        if Calendar.current.isDateInYesterday(info.createdAt){
            return "YESTERDAY"
        }

        return dateFormatter.string(from: info.createdAt)
    }

    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        formatter.dateFormat = "yyyy/MM/dd"
        return formatter
    }()

    func hash(into hasher: inout Hasher) {
        hasher.combine(uri)
    }

    static func == (lhs: DocumentItem, rhs: DocumentItem) -> Bool {
        return lhs.uri == rhs.uri
    }

}

struct DocumentSearchItem: Identifiable, Hashable, Equatable {
    var id: String {
        get {
            info.uri
        }
    }

    var uri: String {
        get {
            info.uri
        }
    }

    var info: EntryInfo

    init(info: EntryInfo) {
        self.info = info
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(info.uri)
    }

    static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.uri == rhs.uri
    }
}

struct SearchResultItem: Identifiable, Hashable {
    var id: String { result.uri }
    let result: SearchResult
    let searchQuery: String

    var title: String { result.title }
    var content: String { result.content }
    var uri: String { result.uri }
    var date: Date { result.changedAt }

    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }()

    var dateString: String {
        dateFormatter.string(from: date)
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(uri)
    }

    static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.uri == rhs.uri
    }
}
