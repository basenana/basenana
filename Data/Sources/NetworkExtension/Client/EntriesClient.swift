//
//  EntriesClient.swift
//  Data
//
//  REST API implementation of Entries client
//

import Foundation
import Entities
import NetworkCore

public class EntriesClient: EntriesClientProtocol {

    private let apiClient: APIClient

    public init(apiClient: APIClient) {
        self.apiClient = apiClient
    }

    public func GroupTree() async throws -> any Entities.Group {
        let response: GroupTreeResponse = try await apiClient.request(.groupsTree, responseType: GroupTreeResponse.self)
        return parseGroupTree(node: response.root)
    }

    public func RootEntry() async throws -> NetworkCore.APIEntryDetail {
        let response: EntryDetailResponse = try await apiClient.request(
            .entriesDetails(uri: "/", id: nil),
            responseType: EntryDetailResponse.self
        )
        return response.entry.toAPIEntryDetail()
    }

    public func FindEntry(parent: Int64, name: String) async throws -> NetworkCore.APIEntryDetail {
        let uri = "/\(parent)/\(name)"
        let response: EntryDetailResponse = try await apiClient.request(
            .entriesDetails(uri: uri, id: nil),
            responseType: EntryDetailResponse.self
        )
        return response.entry.toAPIEntryDetail()
    }

    public func GetEntryDetail(entry: Int64) async throws -> NetworkCore.APIEntryDetail {
        let response: EntryDetailResponse = try await apiClient.request(
            .entriesDetails(uri: nil, id: entry),
            responseType: EntryDetailResponse.self
        )
        return response.entry.toAPIEntryDetail()
    }

    public func CreateEntry(entry: Entities.EntryCreate) async throws -> NetworkCore.APIEntryInfo {
        let request = CreateEntryRequest(
            uri: "/\(entry.parent)/\(entry.name)",
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

    public func UpdateEntry(entry: Entities.EntryUpdate) async throws -> NetworkCore.APIEntryDetail {
        let request = UpdateEntryRequest(name: entry.name, aliases: nil)

        let response: EntryDetailResponse = try await apiClient.request(
            .entriesUpdate(uri: nil, id: entry.id),
            body: request,
            responseType: EntryDetailResponse.self
        )
        return response.entry.toAPIEntryDetail()
    }

    public func DeleteEntries(entrys: [Int64]) async throws {
        throw RepositoryError.unimplement
    }

    public func ListGroupChildren(filter: Entities.EntryFilter) async throws -> [NetworkCore.APIEntryInfo] {
        let orderStr: String?
        switch filter.order {
        case .name: orderStr = "name"
        case .kind: orderStr = "kind"
        case .isGroup: orderStr = "is_group"
        case .size: orderStr = "size"
        case .createdAt: orderStr = "created_at"
        case .modifiedAt: orderStr = "modified_at"
        case .none: orderStr = nil
        }

        let offset: Int? = filter.page.map { Int($0.page * $0.pageSize) }
        let limit: Int? = filter.page.map { Int($0.pageSize) }

        let response: EntriesResponse = try await apiClient.request(
            .groupsChildren(
                uri: nil,
                id: filter.parent,
                offset: offset,
                limit: limit,
                order: orderStr,
                desc: filter.orderDesc
            ),
            responseType: EntriesResponse.self
        )

        return response.entries.map { $0.toAPIEntryInfo() }
    }

    public func ChangeParent(entry: Int64, newParent: Int64, option: Entities.ChangeParentOption) async throws {
        let newUri = "/\(newParent)"
        let request = ChangeParentRequest(
            new_entry_uri: newUri,
            replace: false,
            exchange: false
        )

        _ = try await apiClient.request(
            .entriesParent(uri: nil, id: entry, newUri: newUri),
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
