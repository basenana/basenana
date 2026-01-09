//
//  PaperFlowUseCase.swift
//  Domain
//
//  Created by Hypo on 2024/9/18.
//

public class PaperFlowUseCase: PaperFlowUseCaseProtocol {

    private var entryRepo: EntryRepositoryProtocol

    public init(entryRepo: EntryRepositoryProtocol) {
        self.entryRepo = entryRepo
    }

    public func listUnreadDocuments(page: Pagination) throws -> [any EntryInfo] {
        throw UseCaseError.unimplement
    }

    public func listMarkedDocuments(page: Pagination) throws -> [any EntryInfo] {
        throw UseCaseError.unimplement
    }
}
