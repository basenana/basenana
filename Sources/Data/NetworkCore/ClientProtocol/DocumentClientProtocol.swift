//
//  DocumentClientProtocol.swift
//
//
//  Created by Hypo on 2024/9/15.
//

import Foundation
import Domain


public protocol DocumentClientProtocol {
    func ListDocuments(filter: DocumentFilter) async throws -> [APIDocumentInfo]
    func GetDocumentDetail(id: DocumentID) async throws -> APIDocumentDetail
    func UpdateDocument(doc: DocumentUpdate) async throws
}
