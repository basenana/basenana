//
//  MockUseCase.swift
//  Domain
//
//  Created by Hypo on 2024/9/22.
//

import UseCase
import UseCaseProtocol


public func MockEntryUseCase() -> EntryUseCaseProtocol {
    return EntryUseCase(entryRepo: MockEntryRepository.shared, fileRepo: MockFileRepository.shared)
}

public func MockDocumentUseCase() -> DocumentUseCaseProtocol {
    return DocumentUseCase(docRepo: MockDocRepository.shared, entryRepo: MockEntryRepository.shared)
}

