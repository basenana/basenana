//
//  DocumentRepository.swift
//
//
//  Created by Hypo on 2024/9/15.
//

import Foundation
import Entities
import NetworkCore
import RepositoryProtocol


public class DocumentRepository: DocumentRepositoryProtocol {
    private var core: DocumentClientProtocol
    
    public init(core: DocumentClientProtocol) {
        self.core = core
    }
    
    public func ListDocuments(filter: Entities.DocumentFilter) async throws -> [any Entities.DocumentInfo] {
        return try await core.ListDocuments(filter: filter)
    }
    
    public func GetDocumentDetail(id: Entities.DocumentID) async throws -> any Entities.DocumentDetail {
        return try await core.GetDocumentDetail(id: id)
    }
    
    public func UpdateDocument(doc: Entities.DocumentUpdate) async throws {
        return try await core.UpdateDocument(doc: doc)
    }
    
}
