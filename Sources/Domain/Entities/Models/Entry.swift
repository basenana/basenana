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
    
    
    func toGroup() -> EntryGroup?
}

public protocol EntryDetail {
    var id: Int64 { get }
    var uri: String { get }
    var name: String { get }
    var aliases: String { get }
    var parent: Int64 { get }
    var kind: String { get }
    var isGroup: Bool { get }
    var size: Int64 { get }
    var version: Int64 { get }
    var namespace: String { get }
    var storage: String { get }
    
    var uid: Int64 { get }
    var gid: Int64 { get }
    var permissions: [String] { get }
    
    var createdAt: Date { get }
    var changedAt: Date { get }
    var modifiedAt: Date { get }
    var accessAt: Date { get }
    
    var properties: [EntryProperty] { get }
    
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
    public var documentTitle: String? { nil }
    public var documentAuthor: String? { nil }
    public var documentSource: String? { nil }
    public var documentMarked: Bool { false }
    public var documentUnread: Bool { false }
    public var documentHeaderImage: String? { nil }

    // Legacy DocumentInfo properties
    public var parent: EntryInfo { self }
    public var properties: [EntryProperty] { [] }
    public var subContent: String { "" }
    public var searchContent: [String] { [] }
    public var headerImage: String { "" }
    public var marked: Bool { documentMarked }
    public var unread: Bool { documentUnread }
}

extension EntryDetail {
    public var documentTitle: String? { nil }
    public var documentAuthor: String? { nil }
    public var documentSource: String? { nil }
    public var documentAbstract: String? { nil }
    public var documentKeywords: [String]? { nil }
    public var documentNotes: String? { nil }
    public var documentMarked: Bool { false }
    public var documentUnread: Bool { false }
    public var documentPublishAt: Date? { nil }
    public var documentURL: String? { nil }
    public var documentHeaderImage: String? { nil }
    public var content: String { "" }
}
