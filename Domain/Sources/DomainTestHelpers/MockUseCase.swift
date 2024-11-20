//
//  MockUseCase.swift
//  Domain
//
//  Created by Hypo on 2024/9/22.
//

import UseCase
import UseCaseProtocol


public func MockEntryTreeUseCase() -> EntryTreeUseCaseProtocol {
    return EntryTreeUseCase(entryRepo: MockEntryRepository.shared)
}

public func MockEntryUseCase() -> EntryUseCaseProtocol {
    return EntryUseCase(entryRepo: MockEntryRepository.shared)
}

public func MockDocumentUseCase() -> DocumentUseCaseProtocol {
    return DocumentUseCase(docRepo: MockDocRepository.shared, entryRepo: MockEntryRepository.shared)
}

public func MockInboxUseCase() -> InboxUseCaseProtocol {
    return InboxUseCase(inboxRepo: MockInboxRepository.shared, entryRepo: MockEntryRepository.shared, fileRepo: MockFileRepository.shared)
}
