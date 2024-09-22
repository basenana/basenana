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
        throw UseCaseError.unimplement
    }
    
    public func renameEntry(entry: Int64, newName: String) throws {
        throw UseCaseError.unimplement
    }
    
    public func deleteEntry(entry: Int64) throws {
        throw UseCaseError.unimplement
    }
    
}
