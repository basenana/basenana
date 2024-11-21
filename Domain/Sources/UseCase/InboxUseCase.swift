//
//  InboxUseCase.swift
//
//
//  Created by Hypo on 2024/9/14.
//


import Entities
import RepositoryProtocol
import UseCaseProtocol

public class InboxUseCase: InboxUseCaseProtocol {
    
    private var inboxRepo: InboxRepositoryProtocol
    private var entryRepo: EntryRepositoryProtocol
    private var fileRepo: FileRepositoryProtocol
    
    public init(inboxRepo: InboxRepositoryProtocol, entryRepo: EntryRepositoryProtocol, fileRepo: FileRepositoryProtocol) {
        self.inboxRepo = inboxRepo
        self.entryRepo = entryRepo
        self.fileRepo = fileRepo
    }

    public func quickInbox(url: String, fileName: String, fileType: Entities.FileType) throws {
        throw UseCaseError.unimplement
    }
}
