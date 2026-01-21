//
//  SearchUseCase.swift
//  Domain
//
//  Created by Hypo on 2024/9/18.
//

public class SearchUseCase: SearchUseCaseProtocol {

    private var entryRepo: EntryRepositoryProtocol

    public init(entryRepo: EntryRepositoryProtocol) {
        self.entryRepo = entryRepo
    }

    public func Search(query: String, page: Int?, pageSize: Int?) async throws -> [SearchResult] {
        do {
            return try await entryRepo.Search(query: query, page: page, pageSize: pageSize)
        } catch RepositoryError.canceled {
            throw UseCaseError.canceled
        }
    }
}
