//
//  DocumentUseCaseProtocol.swift
//
//
//  Created by Hypo on 2024/9/13.
//

import Foundation



public protocol DocumentUseCaseProtocol {
    func listUnreadDocuments(page: Int, pageSize: Int) async throws -> [EntryInfo]
    func listMarkedDocuments(page: Int, pageSize: Int) async throws -> [EntryInfo]
    func filterDocuments(search: String,page: Int, pageSize: Int) async throws -> [EntryInfo]

    func getDocumentDetails(uri: String) async throws -> EntryDetail

    func getDocumentEntry(uri: String) async throws -> EntryDetail?

    func setDocumentMarkState(uri: String, ismark: Bool) async throws
    func setDocumentReadState(uri: String, unread: Bool) async throws

    // document metadata update
    func updateDocumentMetadata(uri: String, update: DocumentUpdate) async throws

    // property operations
    func setProperties(uri: String, tags: [String]?, properties: [String: String]?) async throws
    func updateTags(uri: String, tags: [String]) async throws
}
