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
    
    init(core: DocumentClientProtocol) {
        self.core = core
    }
    
    public func ListDocuments(filter: Entities.DocumentFilter) throws -> [any Entities.DocumentInfo] {
        return try core.ListDocuments(filter: filter)
    }
    
    public func GetDocumentDetail(id: Entities.DocumentID) throws -> any Entities.DocumentDetail {
        return try core.GetDocumentDetail(id: id)
    }
    
    public func UpdateDocument(doc: Entities.DocumentUpdate) throws {
        return try core.UpdateDocument(doc: doc)
    }
    
}
