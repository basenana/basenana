//
//  MockUseCase.swift
//  Domain
//
//  Created by Hypo on 2024/9/22.
//


import UseCase

public func MockEntryTreeUseCase() -> EntryTreeUseCase {
    return EntryTreeUseCase(entryRepo: MockEntryRepository.shared)
}

public func MockEntryUseCase() -> EntryUseCase {
    return EntryUseCase(entryRepo: MockEntryRepository.shared)
}

public func MockDocumentUseCase() -> DocumentUseCase {
    return DocumentUseCase(docRepo: MockDocRepository.shared)
}

public func MockInboxUseCase() -> InboxUseCase {
    return InboxUseCase(inboxRepo: MockInboxRepository.shared, entryRepo: MockEntryRepository.shared, fileRepo: MockFileRepository.shared)
}
