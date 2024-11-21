//
//  EntryUseCase.swift
//  Domain
//
//  Created by Hypo on 2024/9/18.
//


import Entities
import RepositoryProtocol
import UseCaseProtocol

public class EntryUseCase: EntryUseCaseProtocol {
    private var entryRepo: EntryRepositoryProtocol
    
    public init(entryRepo: EntryRepositoryProtocol) {
        self.entryRepo = entryRepo
    }
    
    public func getEntryDetails(entry: Int64) throws -> any Entities.EntryDetail {
        return try entryRepo.GetEntryDetail(entry: entry)
    }
    
    public func renameEntry(entry: Int64, newName: String) throws {
        let en = try getEntryDetails(entry: entry)
        var opt = ChangeParentOption()
        opt.newName = newName
        return try entryRepo.ChangeParent(entry: en.id, newParent: en.parent, option: opt)
    }
    
    public func deleteEntry(entry: Int64) throws {
        try entryRepo.DeleteEntries(entrys: [entry])
    }
    
}
