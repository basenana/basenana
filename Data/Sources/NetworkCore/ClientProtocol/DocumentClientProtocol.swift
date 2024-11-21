//
//  DocumentClientProtocol.swift
//
//
//  Created by Hypo on 2024/9/15.
//

import Foundation
import Entities


public protocol DocumentClientProtocol {
    func ListDocuments(filter: DocumentFilter) throws -> [APIDocumentInfo]
    func GetDocumentDetail(id: DocumentID) throws -> APIDocumentDetail
    func UpdateDocument(doc: DocumentUpdate) throws
}
