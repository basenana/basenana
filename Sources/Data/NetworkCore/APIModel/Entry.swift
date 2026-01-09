//
//  Entry.swift
//  basenana
//
//  Created by Hypo on 2024/2/29.
//

import SwiftData
import Foundation
import Domain

// MARK: - Public Document Info Wrapper

public struct DocumentInfo {
    public var title: String?
    public var author: String?
    public var year: String?
    public var source: String?
    public var abstract: String?
    public var keywords: [String]?
    public var notes: String?
    public var unread: Bool?
    public var marked: Bool?
    public var publishAt: Date?
    public var url: String?
    public var headerImage: String?

    public init() { }

    init(from dto: DocumentWrapperDTO?) {
        self.title = dto?.title
        self.author = dto?.author
        self.year = dto?.year
        self.source = dto?.source
        self.abstract = dto?.abstract
        self.keywords = dto?.keywords
        self.notes = dto?.notes
        self.unread = dto?.unread
        self.marked = dto?.marked
        self.publishAt = dto?.publish_at
        self.url = dto?.url
        self.headerImage = dto?.header_image
    }
}

public struct APIEntryInfo: EntryInfo {
    public var id: Int64
    public var uri: String

    public var name: String

    public var kind: String

    public var isGroup: Bool

    public var size: Int64

    public var parentID: Int64

    public var createdAt: Date

    public var changedAt: Date

    public var modifiedAt: Date

    public var accessAt: Date

    public init(id: Int64, uri: String, name: String, kind: String, isGroup: Bool, size: Int64, parentID: Int64, createdAt: Date, changedAt: Date, modifiedAt: Date, accessAt: Date) {
        self.id = id
        self.uri = uri
        self.name = name
        self.kind = kind
        self.isGroup = isGroup
        self.size = size
        self.parentID = parentID
        self.createdAt = createdAt
        self.changedAt = changedAt
        self.modifiedAt = modifiedAt
        self.accessAt = accessAt
    }

    public func toGroup() -> (any EntryGroup)? {
        if !self.isGroup {
            return nil
        }
        return APIGroup(id: id, uri: uri, groupName: name, parentID: parentID)
    }
}

public struct APIEntryDetail: EntryDetail {
    public var id: Int64
    public var uri: String

    public var name: String

    public var aliases: String

    public var parent: Int64

    public var kind: String

    public var isGroup: Bool

    public var size: Int64

    public var version: Int64

    public var namespace: String

    public var storage: String

    public var uid: Int64

    public var gid: Int64

    public var permissions: [String]

    public var createdAt: Date

    public var changedAt: Date

    public var modifiedAt: Date

    public var accessAt: Date

    public var properties: [any EntryProperty]

    public var document: DocumentInfo?

    public init(id: Int64, uri: String, name: String, aliases: String, parent: Int64, kind: String, isGroup: Bool, size: Int64, version: Int64, namespace: String, storage: String, uid: Int64, gid: Int64, permissions: [String], createdAt: Date, changedAt: Date, modifiedAt: Date, accessAt: Date, properties: [any EntryProperty], document: DocumentInfo? = nil) {
        self.id = id
        self.uri = uri
        self.name = name
        self.aliases = aliases
        self.parent = parent
        self.kind = kind
        self.isGroup = isGroup
        self.size = size
        self.version = version
        self.namespace = namespace
        self.storage = storage
        self.uid = uid
        self.gid = gid
        self.permissions = permissions
        self.createdAt = createdAt
        self.changedAt = changedAt
        self.modifiedAt = modifiedAt
        self.accessAt = accessAt
        self.properties = properties
        self.document = document
    }

    public func toInfo() -> (any EntryInfo)? {
        return APIEntryInfo(id: id, uri: uri, name: name, kind: kind, isGroup: isGroup, size: size, parentID: parent, createdAt: createdAt, changedAt: changedAt, modifiedAt: modifiedAt, accessAt: accessAt)
    }


    public func toGroup() -> (any EntryGroup)? {
        if !self.isGroup {
            return nil
        }
        return APIGroup(id: id, uri: uri, groupName: name, parentID: parent)
    }
}

public struct APIEntryProperty: EntryProperty {
    public var key: String

    public var value: String

    public var encoded: Bool

    public init(key: String, value: String, encoded: Bool) {
        self.key = key
        self.value = value
        self.encoded = encoded
    }
}

// MARK: - Document Properties Extension for APIEntryInfo

extension APIEntryInfo {
    public var documentTitle: String? { nil }
    public var documentAuthor: String? { nil }
    public var documentSource: String? { nil }
    public var documentMarked: Bool { false }
    public var documentUnread: Bool { false }
}

// MARK: - Document Properties Extension for APIEntryDetail

extension APIEntryDetail {
    public var documentTitle: String? { document?.title }
    public var documentAuthor: String? { document?.author }
    public var documentSource: String? { document?.source }
    public var documentAbstract: String? { document?.abstract }
    public var documentKeywords: [String]? { document?.keywords }
    public var documentNotes: String? { document?.notes }
    public var documentMarked: Bool { document?.marked ?? false }
    public var documentUnread: Bool { document?.unread ?? false }
    public var documentPublishAt: Date? { document?.publishAt }
    public var documentURL: String? { document?.url }
    public var documentHeaderImage: String? { document?.headerImage }
}
