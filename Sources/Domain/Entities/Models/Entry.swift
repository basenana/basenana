//
//  Entry.swift
//  
//
//  Created by Hypo on 2024/9/13.
//

import Foundation

public protocol EntryInfo {
    var id: Int64 { get }
    var uri: String { get }
    var name: String { get }
    var kind: String { get }
    var isGroup: Bool { get }
    var size: Int64 { get }
    var parentID: Int64 { get }

    var createdAt: Date { get }
    var changedAt: Date { get }
    var modifiedAt: Date { get }
    var accessAt: Date { get }

    // Document properties - must be implemented by concrete types
    var documentTitle: String? { get }
    var documentAuthor: String? { get }
    var documentYear: String? { get }
    var documentSource: String? { get }
    var documentAbstract: String? { get }
    var documentKeywords: [String]? { get }
    var documentNotes: String? { get }
    var documentURL: String? { get }
    var documentHeaderImage: String? { get }
    var documentMarked: Bool { get }
    var documentUnread: Bool { get }
    var documentPublishAt: Date? { get }
    var documentSiteName: String? { get }
    var documentSiteURL: String? { get }

    func toGroup() -> EntryGroup?
}

public protocol EntryDetail {
    var id: Int64 { get }
    var uri: String { get }
    var name: String { get }
    var aliases: String? { get }
    var parent: Int64 { get }
    var kind: String { get }
    var isGroup: Bool { get }
    var size: Int64 { get }
    var version: Int64? { get }
    var namespace: String? { get }
    var storage: String? { get }

    var uid: Int64? { get }
    var gid: Int64? { get }
    var permissions: [String]? { get }

    var createdAt: Date { get }
    var changedAt: Date { get }
    var modifiedAt: Date { get }
    var accessAt: Date { get }

    var properties: [EntryProperty] { get }

    // Document properties
    var documentTitle: String? { get }
    var documentAuthor: String? { get }
    var documentYear: String? { get }
    var documentSource: String? { get }
    var documentAbstract: String? { get }
    var documentKeywords: [String]? { get }
    var documentNotes: String? { get }
    var documentURL: String? { get }
    var documentHeaderImage: String? { get }
    var documentMarked: Bool { get }
    var documentUnread: Bool { get }
    var documentPublishAt: Date? { get }
    var documentSiteName: String? { get }
    var documentSiteURL: String? { get }

    func toInfo() -> EntryInfo?
    func toGroup() -> EntryGroup?
}


public func entryTitleName(en: EntryInfo) -> String {
    if !isVisitable(en: en){
        return ""
    }
    return en.name.uppercased()
}

public func isVisitable(en: EntryInfo) -> Bool{
    return !en.name.starts(with: ".")
}

public func isVisitable(en: EntryDetail) -> Bool{
    return !en.name.starts(with: ".")
}

public protocol EntryProperty {
    var key: String { get }
    var value : String { get }
    var encoded: Bool { get }
}


public struct EntryCreate {
    public var parentUri: String
    public var name: String
    public var kind: String

    public var RSS: RSSConfig?

    public init(parentUri: String, name: String, kind: String) {
        self.parentUri = parentUri
        self.name = name
        self.kind = kind
        self.RSS = nil
    }
}

public enum FileType: String {
    case xml
    case json
    case markdown
    case webarchive

    public init?(option: String) {
        self.init(rawValue: option)
    }

    public func option() -> String {
        return rawValue
    }
}

public struct RSSConfig {
    public var feed: String
    public var siteName: String
    public var siteURL: String
    public var fileType: FileType
    
    public init(feed: String, siteName: String, siteURL: String, fileType: FileType) {
        self.feed = feed
        self.siteName = siteName
        self.siteURL = siteURL
        self.fileType = fileType
    }
}

public struct EntryUpdate {
    public var id: Int64
    public var name: String?
}

public struct ChangeParentOption{
    public var newName: String = ""
    public init(){ }
}

public struct EntryFilter {
    public var parentUri: String
    public var kind: String? = nil
    public var groupOnly: Bool? = nil
    public var fileOnly: Bool? = nil
    public var page: Pagination? = nil
    public var order: EntryOrder? = nil
    public var orderDesc: Bool? = nil

    public init(parentUri: String) {
        self.parentUri = parentUri
    }
}

public enum EntryOrder {
    case name
    case kind
    case isGroup
    case size
    case createdAt
    case modifiedAt
}

public struct DocumentFilter {
    public var unread: Bool? = nil
    public var marked: Bool? = nil
    public var search: String? = nil
    public var page: Pagination? = nil
    public var order: EntryOrder? = nil
    public var orderDesc: Bool? = nil

    public init() { }
}

// MARK: - Document Properties Protocol Extensions

extension EntryInfo {
    // Document properties with default implementations for types that don't have document info
    public var documentTitle: String? { nil }
    public var documentAuthor: String? { nil }
    public var documentYear: String? { nil }
    public var documentSource: String? { nil }
    public var documentAbstract: String? { nil }
    public var documentKeywords: [String]? { nil }
    public var documentNotes: String? { nil }
    public var documentURL: String? { nil }
    public var documentHeaderImage: String? { nil }
    public var documentMarked: Bool { false }
    public var documentUnread: Bool { false }
    public var documentPublishAt: Date? { nil }
    public var documentSiteName: String? { nil }
    public var documentSiteURL: String? { nil }

    // Legacy DocumentInfo properties (deprecated)
    public var parent: EntryInfo { self }
    public var properties: [EntryProperty] { [] }
    public var subContent: String { "" }
    public var searchContent: [String] { [] }
    public var headerImage: String { "" }
    public var marked: Bool { documentMarked }
    public var unread: Bool { documentUnread }

    // Parent info parsed from URI (API no longer returns parent entry info)
    public var parentName: String {
        let components = uri.split(separator: "/").filter { !$0.isEmpty }
        guard components.count >= 2 else { return "" }
        return String(components[components.count - 2])
    }

    public var parentURI: String {
        let components = uri.split(separator: "/").filter { !$0.isEmpty }
        guard components.count >= 2 else { return "/" }
        let parentPath = components.dropLast().joined(separator: "/")
        return "/\(parentPath)"
    }
}

extension EntryDetail {
    public var documentTitle: String? { nil }
    public var documentAuthor: String? { nil }
    public var documentYear: String? { nil }
    public var documentSource: String? { nil }
    public var documentAbstract: String? { nil }
    public var documentKeywords: [String]? { nil }
    public var documentNotes: String? { nil }
    public var documentURL: String? { nil }
    public var documentHeaderImage: String? { nil }
    public var documentMarked: Bool { false }
    public var documentUnread: Bool { false }
    public var documentPublishAt: Date? { nil }
    public var documentSiteName: String? { nil }
    public var documentSiteURL: String? { nil }
    public var content: String { "" }
}
