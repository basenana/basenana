//
//  EntryRepository.swift
//
//
//  Created by Hypo on 2024/9/15.
//

import Foundation
import Domain
import Data
import Domain


public class EntryRepository: EntryRepositoryProtocol {

    private var core: EntriesClientProtocol

    public init(core: EntriesClientProtocol) {
        self.core = core
    }

    public func GroupTree() async throws -> any EntryGroup {
        return try await core.GroupTree()
    }

    public func RootEntry() async throws -> any EntryDetail {
        return try await core.RootEntry()
    }

    public func FindEntry(parentUri: String, name: String) async throws -> any EntryDetail {
        return try await core.FindEntry(parentUri: parentUri, name: name)
    }

    public func GetEntryDetail(uri: String) async throws -> any EntryDetail {
        return try await core.GetEntryDetail(uri: uri)
    }

    public func CreateEntry(entry: EntryCreate) async throws -> any EntryInfo {
        return try await core.CreateEntry(entry: entry)
    }

    public func UpdateEntry(uri: String, name: String?) async throws -> any EntryDetail {
        return try await core.UpdateEntry(uri: uri, name: name)
    }

    public func DeleteEntries(uris: [String]) async throws {
        return try await core.DeleteEntries(uris: uris)
    }

    public func ListGroupChildren(parentUri: String) async throws -> [any EntryInfo] {
        return try await core.ListGroupChildren(parentUri: parentUri)
    }

    public func ChangeParent(uri: String, newParentUri: String, option: ChangeParentOption) async throws {
        return try await core.ChangeParent(uri: uri, newParentUri: newParentUri, option: option)
    }

    public func AddProperty(entry: Int64, key: String, val: String) async throws {
        return try await core.AddProperty(entry: entry, key: key, val: val)
    }

    public func UpdateProperty(entry: Int64, key: String, val: String) async throws {
        return try await core.UpdateProperty(entry: entry, key: key, val: val)
    }

    public func DeleteProperty(entry: Int64, key: String) async throws {
        return try await core.DeleteProperty(entry: entry, key: key)
    }

    // MARK: - Document Operations

    public func ListDocuments(filter: DocumentFilter) async throws -> [any EntryInfo] {
        var pattern = ""
        if let unread = filter.unread {
            pattern = "unread"
        }
        if let marked = filter.marked {
            pattern = "marked"
        }
        return try await core.SearchEntries(celPattern: pattern, offset: nil, limit: nil)
    }

    public func UpdateDocument(uri: String, unread: Bool?, marked: Bool?) async throws {
        try await core.UpdateDocumentByURI(uri: uri, unread: unread, marked: marked)
    }

}

