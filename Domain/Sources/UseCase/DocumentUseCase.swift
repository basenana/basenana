//
//  DocumentUseCase.swift
//  Domain
//
//  Created by Hypo on 2024/9/18.
//

import Entities
import RepositoryProtocol
import UseCaseProtocol

public class DocumentUseCase: DocumentUseCaseProtocol {
    
    private var docRepo: DocumentRepositoryProtocol
    
    public init(docRepo: DocumentRepositoryProtocol) {
        self.docRepo = docRepo
    }
    
    public func getDocumentDetails(entry: Int64) throws -> any Entities.DocumentDetail {
        throw UseCaseError.unimplement
    }
    
    public func getDocumentDetails(document: Int64) throws -> any Entities.DocumentDetail {
        throw UseCaseError.unimplement
    }
    
    public func setDocumentMarkState(ismark: Bool) throws {
        throw UseCaseError.unimplement
    }
    
    public func setDocumentReadState(unread: Bool) throws {
        throw UseCaseError.unimplement
    }
}
