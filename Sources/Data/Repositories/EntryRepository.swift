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

    public func ListGroupChildren(parentUri: String, page: Int?, pageSize: Int?, sort: String?, order: String?) async throws -> [any EntryInfo] {
        return try await core.ListGroupChildren(parentUri: parentUri, page: page, pageSize: pageSize, sort: sort, order: order)
    }

    public func ChangeParent(uri: String, newEntryUri: String, option: ChangeParentOption) async throws {
        return try await core.ChangeParent(uri: uri, newEntryUri: newEntryUri, option: option)
    }

    public func SetProperties(entry: Int64, tags: [String]?, properties: [String: String]?) async throws {
        return try await core.SetProperties(entry: entry, tags: tags, properties: properties)
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

        let page = filter.page.map { Int($0.page) }
        let pageSize = filter.page.map { Int($0.pageSize) }
        // API 支持: created_at, changed_at, name
        let sort: String? = {
            guard let order = filter.order else { return nil }
            switch order {
            case .name: return "name"
            case .createdAt: return "created_at"
            case .modifiedAt: return "changed_at"
            default: return nil
            }
        }()
        let order = filter.orderDesc == true ? "desc" : "asc"

        return try await core.FilterEntries(celPattern: pattern, page: page, pageSize: pageSize, sort: sort, order: order)
    }

    public func UpdateDocument(uri: String, update: DocumentUpdate) async throws {
        try await core.UpdateDocumentByURI(uri: uri, update: update)
    }

}

