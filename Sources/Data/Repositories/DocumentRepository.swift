//
//  DocumentRepository.swift
//
//
//  Created by Hypo on 2024/9/15.
//

import Foundation
import Domain
import Data
import Domain


public class DocumentRepository: DocumentRepositoryProtocol {
    private var core: DocumentClientProtocol
    
    public init(core: DocumentClientProtocol) {
        self.core = core
    }
    
    public func ListDocuments(filter: DocumentFilter) async throws -> [any DocumentInfo] {
        return try await core.ListDocuments(filter: filter)
    }
    
    public func GetDocumentDetail(id: DocumentID) async throws -> any DocumentDetail {
        return try await core.GetDocumentDetail(id: id)
    }
    
    public func UpdateDocument(doc: DocumentUpdate) async throws {
        return try await core.UpdateDocument(doc: doc)
    }
    
}
