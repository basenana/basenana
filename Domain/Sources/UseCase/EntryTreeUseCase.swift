//
//  EntryTreeUseCase.swift
//  Domain
//
//  Created by Hypo on 2024/9/18.
//


import Entities
import RepositoryProtocol
import UseCaseProtocol

public class EntryTreeUseCase: EntryTreeUseCaseProtocol {
    
    private var entryRepo: EntryRepositoryProtocol
    
    public init(entryRepo: EntryRepositoryProtocol) {
        self.entryRepo = entryRepo
    }
    
    public func getTreeRoot() throws -> any Entities.Group {
        return try entryRepo.GroupTree()
    }
    
    public func listChildren(entry: Int64) throws -> [any Entities.EntryInfo] {
        return try entryRepo.ListGroupChildren(filter: EntryFilter(parent: entry))
    }
    
    public func changeParent(entry: Int64, newParent: Int64) throws {
        return try entryRepo.ChangeParent(entry: entry, newParent: newParent, option: ChangeParentOption())
    }
    
    public func deleteEntries(entries: [Int64]) throws {
        return try entryRepo.DeleteEntries(entrys: entries)
    }
    
}
