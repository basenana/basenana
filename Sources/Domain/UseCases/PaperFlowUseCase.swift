//
//  PaperFlowUseCase.swift
//  Domain
//
//  Created by Hypo on 2024/9/18.
//





public class PaperFlowUseCase: PaperFlowUseCaseProtocol {
    
    private var entryRepo: EntryRepositoryProtocol
    private var docRepo: DocumentRepositoryProtocol
    
    public init(entryRepo: EntryRepositoryProtocol, docRepo: DocumentRepositoryProtocol) {
        self.entryRepo = entryRepo
        self.docRepo = docRepo
    }
    
    public func listUnreadDocuments(page:  Pagination) throws -> [any  DocumentInfo] {
        throw UseCaseError.unimplement
    }
    
    public func listMarkedDocuments(page:  Pagination) throws -> [any  DocumentInfo] {
        throw UseCaseError.unimplement
    }
}
