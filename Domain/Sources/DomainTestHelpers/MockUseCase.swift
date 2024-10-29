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
