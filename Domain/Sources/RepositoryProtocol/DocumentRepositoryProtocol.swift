//
//  DocumentRepositoryProtocol.swift
//
//
//  Created by Hypo on 2024/9/15.
//

import Foundation
import Entities


public protocol DocumentRepositoryProtocol {
    func ListDocuments(filter: DocumentFilter) async throws -> [DocumentInfo]
    func GetDocumentDetail(id: DocumentID) async throws -> DocumentDetail
    func UpdateDocument(doc: DocumentUpdate) async throws
}
