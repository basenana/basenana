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
    public var siteName: String?
    public var siteURL: String?

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
        self.siteName = dto?.site_name
        self.siteURL = dto?.site_url
    }
}

extension DocumentInfo: Decodable {
    enum CodingKeys: String, CodingKey {
        case title, author, year, source, abstract, keywords, notes
        case unread, marked
        case publishAt = "publish_at"
        case url
        case headerImage = "header_image"
        case siteName = "site_name"
        case siteURL = "site_url"
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.title = try container.decodeIfPresent(String.self, forKey: .title)
        self.author = try container.decodeIfPresent(String.self, forKey: .author)
        self.year = try container.decodeIfPresent(String.self, forKey: .year)
        self.source = try container.decodeIfPresent(String.self, forKey: .source)
        self.abstract = try container.decodeIfPresent(String.self, forKey: .abstract)
        self.keywords = try container.decodeIfPresent([String].self, forKey: .keywords)
        self.notes = try container.decodeIfPresent(String.self, forKey: .notes)
        self.unread = try container.decodeIfPresent(Bool.self, forKey: .unread)
        self.marked = try container.decodeIfPresent(Bool.self, forKey: .marked)
        self.publishAt = try container.decodeIfPresent(Date.self, forKey: .publishAt)
        self.url = try container.decodeIfPresent(String.self, forKey: .url)
        self.headerImage = try container.decodeIfPresent(String.self, forKey: .headerImage)
        self.siteName = try container.decodeIfPresent(String.self, forKey: .siteName)
        self.siteURL = try container.decodeIfPresent(String.self, forKey: .siteURL)
    }
}

// MARK: - API Entry Info

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
    public var document: DocumentInfo?

    public init(id: Int64, uri: String, name: String, kind: String, isGroup: Bool, size: Int64, parentID: Int64, createdAt: Date, changedAt: Date, modifiedAt: Date, accessAt: Date, document: DocumentInfo? = nil) {
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
        self.document = document
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

    public var aliases: String?

    public var parent: Int64

    public var kind: String

    public var isGroup: Bool

    public var size: Int64

    public var version: Int64?

    public var namespace: String?

    public var storage: String?

    public var uid: Int64?

    public var gid: Int64?

    public var permissions: [String]?

    public var createdAt: Date

    public var changedAt: Date

    public var modifiedAt: Date

    public var accessAt: Date

    public var property: EntryPropertyInfo?

    public var document: DocumentInfo?

    public init(id: Int64, uri: String, name: String, aliases: String?, parent: Int64, kind: String, isGroup: Bool, size: Int64, version: Int64?, namespace: String?, storage: String?, uid: Int64?, gid: Int64?, permissions: [String]?, createdAt: Date, changedAt: Date, modifiedAt: Date, accessAt: Date, property: EntryPropertyInfo?, document: DocumentInfo? = nil) {
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
        self.permissions = permissions ?? []
        self.createdAt = createdAt
        self.changedAt = changedAt
        self.modifiedAt = modifiedAt
        self.accessAt = accessAt
        self.property = property
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

extension APIEntryDetail: Decodable {
    enum CodingKeys: String, CodingKey {
        case id, uri, name, aliases, parent, kind, isGroup, size, version
        case namespace, storage, uid, gid, permissions
        case createdAt = "created_at"
        case changedAt = "changed_at"
        case modifiedAt = "modified_at"
        case accessAt = "access_at"
        case property, document
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(Int64.self, forKey: .id)
        self.uri = try container.decode(String.self, forKey: .uri)
        self.name = try container.decode(String.self, forKey: .name)
        self.aliases = try container.decodeIfPresent(String.self, forKey: .aliases)
        self.parent = try container.decode(Int64.self, forKey: .parent)
        self.kind = try container.decode(String.self, forKey: .kind)
        self.isGroup = try container.decode(Bool.self, forKey: .isGroup)
        self.size = try container.decode(Int64.self, forKey: .size)
        self.version = try container.decodeIfPresent(Int64.self, forKey: .version)
        self.namespace = try container.decodeIfPresent(String.self, forKey: .namespace)
        self.storage = try container.decodeIfPresent(String.self, forKey: .storage)
        self.uid = try container.decodeIfPresent(Int64.self, forKey: .uid)
        self.gid = try container.decodeIfPresent(Int64.self, forKey: .gid)
        self.permissions = try container.decodeIfPresent([String].self, forKey: .permissions)
        self.createdAt = try container.decode(Date.self, forKey: .createdAt)
        self.changedAt = try container.decode(Date.self, forKey: .changedAt)
        self.modifiedAt = try container.decode(Date.self, forKey: .modifiedAt)
        self.accessAt = try container.decode(Date.self, forKey: .accessAt)

        let propertyDTO = try container.decodeIfPresent(PropertyWrapperDTO.self, forKey: .property)
        self.property = EntryPropertyInfo(tags: propertyDTO?.tags, properties: propertyDTO?.properties)

        self.document = try container.decodeIfPresent(DocumentInfo.self, forKey: .document)
    }
}

// MARK: - Property Info Extension for APIEntryDetail

extension APIEntryDetail {
    public var entryTags: [String]? { property?.tags }
    public var entryProperties: [String: String]? { property?.properties }
}

// MARK: - Document Properties Extension for APIEntryInfo

extension APIEntryInfo {
    public var documentTitle: String? { document?.title }
    public var documentAuthor: String? { document?.author }
    public var documentYear: String? { document?.year }
    public var documentSource: String? { document?.source }
    public var documentAbstract: String? { document?.abstract }
    public var documentKeywords: [String]? { document?.keywords }
    public var documentNotes: String? { document?.notes }
    public var documentURL: String? { document?.url }
    public var documentHeaderImage: String? { document?.headerImage }
    public var documentMarked: Bool { document?.marked ?? false }
    public var documentUnread: Bool { document?.unread ?? false }
    public var documentPublishAt: Date? { document?.publishAt }
    public var documentSiteName: String? { document?.siteName }
    public var documentSiteURL: String? { document?.siteURL }
}

// MARK: - Document Properties Extension for APIEntryDetail

extension APIEntryDetail {
    public var documentTitle: String? { document?.title }
    public var documentAuthor: String? { document?.author }
    public var documentYear: String? { document?.year }
    public var documentSource: String? { document?.source }
    public var documentAbstract: String? { document?.abstract }
    public var documentKeywords: [String]? { document?.keywords }
    public var documentNotes: String? { document?.notes }
    public var documentURL: String? { document?.url }
    public var documentHeaderImage: String? { document?.headerImage }
    public var documentMarked: Bool { document?.marked ?? false }
    public var documentUnread: Bool { document?.unread ?? false }
    public var documentPublishAt: Date? { document?.publishAt }
    public var documentSiteName: String? { document?.siteName }
    public var documentSiteURL: String? { document?.siteURL }
}
