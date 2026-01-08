//
//  DocumentClient.swift
//  Data
//
//  REST API implementation of Document client
//

import Foundation
import Entities
import NetworkCore

public class DocumentClient: DocumentClientProtocol {

    private let apiClient: APIClient

    public init(apiClient: APIClient) {
        self.apiClient = apiClient
    }

    public func ListDocuments(filter: Entities.DocumentFilter) async throws -> [APIDocumentInfo] {
        // Documents are returned via entries search with CEL pattern
        let searchRequest = SearchRequest(cel_pattern: "entry.kind == 'document'")

        let response: EntriesResponse = try await apiClient.request(
            .entriesSearch,
            body: searchRequest,
            responseType: EntriesResponse.self
        )

        // Convert entries to document infos
        return response.entries.map { entryDTO in
            APIDocumentInfo(
                id: entryDTO.entry,
                oid: entryDTO.entry,
                parentId: 0,
                name: entryDTO.name,
                namespace: "",
                source: nil,
                marked: false,
                unread: false,
                subContent: "",
                searchContent: [],
                headerImage: "",
                createdAt: entryDTO.created_at,
                changedAt: entryDTO.changed_at,
                properties: [],
                parent: entryDTO.toAPIEntryInfo()
            )
        }
    }

    public func GetDocumentDetail(id: Entities.DocumentID) async throws -> APIDocumentDetail {
        let entryId = id.documentID > 0 ? id.documentID : id.entryID

        let response: EntryDetailResponse = try await apiClient.request(
            .entriesDetails(uri: nil, id: entryId),
            responseType: EntryDetailResponse.self
        )

        let doc = response.entry.document

        return APIDocumentDetail(
            id: response.entry.entry,
            oid: response.entry.entry,
            parentId: response.entry.parent ?? 0,
            name: response.entry.name,
            namespace: response.entry.namespace,
            source: doc?.source,
            marked: doc?.marked ?? false,
            unread: doc?.unread ?? false,
            keyWords: doc?.keywords,
            content: "",
            summary: doc?.abstract,
            createdAt: response.entry.created_at,
            changedAt: response.entry.changed_at
        )
    }

    public func UpdateDocument(doc: Entities.DocumentUpdate) async throws {
        let request = DocumentRequest(unread: doc.unread, marked: doc.marked)

        _ = try await apiClient.request(
            .entriesDocument(uri: nil, id: doc.docId),
            body: request,
            responseType: DocumentWrapperDTO.self
        )
    }
}
