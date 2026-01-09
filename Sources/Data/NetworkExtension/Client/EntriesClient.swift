//
//  EntriesClient.swift
//  Data
//
//  REST API implementation of Entries client
//

import Foundation
import Domain
import Data

public class EntriesClient: EntriesClientProtocol {

    private let apiClient: APIClient

    public init(apiClient: APIClient) {
        self.apiClient = apiClient
    }

    public func GroupTree() async throws -> any EntryGroup {
        let response: GroupTreeResponse = try await apiClient.request(.groupsTree, responseType: GroupTreeResponse.self)
        return parseGroupTree(node: response.root)
    }

    public func RootEntry() async throws -> APIEntryDetail {
        let response: EntryDetailResponse = try await apiClient.request(
            .entriesDetails(uri: "/", id: nil),
            responseType: EntryDetailResponse.self
        )
        return response.entry.toAPIEntryDetail()
    }

    public func FindEntry(parentUri: String, name: String) async throws -> APIEntryDetail {
        let uri = "\(parentUri)/\(name)"
        let response: EntryDetailResponse = try await apiClient.request(
            .entriesDetails(uri: uri, id: nil),
            responseType: EntryDetailResponse.self
        )
        return response.entry.toAPIEntryDetail()
    }

    public func GetEntryDetail(uri: String) async throws -> APIEntryDetail {
        let response: EntryDetailResponse = try await apiClient.request(
            .entriesDetails(uri: uri, id: nil),
            responseType: EntryDetailResponse.self
        )
        return response.entry.toAPIEntryDetail()
    }

    public func CreateEntry(entry: EntryCreate) async throws -> APIEntryInfo {
        let request = CreateEntryRequest(
            uri: "\(entry.parentUri)/\(entry.name)",
            kind: entry.kind,
            rss: entry.RSS.map { RSSConfigRequest(
                feed: $0.feed,
                site_name: $0.siteName,
                site_url: $0.siteURL,
                file_type: $0.fileType.option()
            )},
            filter: nil
        )

        let response: EntryDetailResponse = try await apiClient.request(
            .entriesCreate,
            body: request,
            responseType: EntryDetailResponse.self
        )
        return response.entry.toAPIEntryInfo()
    }

    public func UpdateEntry(uri: String, name: String?) async throws -> APIEntryDetail {
        let request = UpdateEntryRequest(name: name, aliases: nil)

        let response: EntryDetailResponse = try await apiClient.request(
            .entriesUpdate(uri: uri, id: nil),
            body: request,
            responseType: EntryDetailResponse.self
        )
        return response.entry.toAPIEntryDetail()
    }

    public func DeleteEntries(uris: [String]) async throws {
        throw RepositoryError.unimplement
    }

    public func ListGroupChildren(parentUri: String) async throws -> [APIEntryInfo] {
        let response: EntriesResponse = try await apiClient.request(
            .groupsChildren(
                uri: parentUri,
                id: nil,
                offset: nil,
                limit: nil,
                order: nil,
                desc: nil
            ),
            responseType: EntriesResponse.self
        )

        return response.entries.map { $0.toAPIEntryInfo() }
    }

    public func ChangeParent(uri: String, newParentUri: String, option: ChangeParentOption) async throws {
        let request = ChangeParentRequest(
            new_entry_uri: newParentUri,
            replace: false,
            exchange: false
        )

        _ = try await apiClient.request(
            .entriesParent(uri: uri, id: nil, newUri: newParentUri),
            body: request,
            responseType: EntryDetailResponse.self
        )
    }

    public func AddProperty(entry: Int64, key: String, val: String) async throws {
        let request = PropertyRequest(tags: nil, properties: [key: val])

        _ = try await apiClient.request(
            .entriesProperty(uri: nil, id: entry),
            body: request,
            responseType: PropertyWrapperDTO.self
        )
    }

    public func UpdateProperty(entry: Int64, key: String, val: String) async throws {
        let request = PropertyRequest(tags: nil, properties: [key: val])

        _ = try await apiClient.request(
            .entriesProperty(uri: nil, id: entry),
            body: request,
            responseType: PropertyWrapperDTO.self
        )
    }

    public func DeleteProperty(entry: Int64, key: String) async throws {
        throw RepositoryError.unimplement
    }

    // MARK: - Private Helpers

    private func parseGroupTree(node: GroupTreeNodeDTO) -> APIGroup {
        let children = node.children?.map { parseGroupTree(node: $0) }
        return APIGroup(
            id: 0,
            uri: node.uri,
            groupName: node.name,
            parentID: 0,
            children: children
        )
    }
}

// MARK: - DTO Extensions

extension EntryDetailDTO {
    func toAPIEntryDetail() -> APIEntryDetail {
        APIEntryDetail(
            id: self.entry,
            uri: self.uri,
            name: self.name,
            aliases: self.aliases,
            parent: 0,
            kind: self.kind,
            isGroup: self.is_group,
            size: self.size,
            version: self.version,
            namespace: self.namespace,
            storage: self.storage,
            uid: self.access?.uid ?? 0,
            gid: self.access?.gid ?? 0,
            permissions: self.access?.permissions ?? [],
            createdAt: self.created_at,
            changedAt: self.changed_at,
            modifiedAt: self.modified_at,
            accessAt: self.access_at,
            properties: []
        )
    }

    func toAPIEntryInfo() -> APIEntryInfo {
        APIEntryInfo(
            id: self.entry,
            uri: self.uri,
            name: self.name,
            kind: self.kind,
            isGroup: self.is_group,
            size: self.size,
            parentID: 0,
            createdAt: self.created_at,
            changedAt: self.changed_at,
            modifiedAt: self.modified_at,
            accessAt: self.access_at
        )
    }
}

extension EntryInfoDTO {
    func toAPIEntryInfo() -> APIEntryInfo {
        APIEntryInfo(
            id: self.entry,
            uri: self.uri,
            name: self.name,
            kind: self.kind,
            isGroup: self.is_group,
            size: self.size,
            parentID: 0,
            createdAt: self.created_at,
            changedAt: self.changed_at,
            modifiedAt: self.modified_at,
            accessAt: self.access_at
        )
    }
}
