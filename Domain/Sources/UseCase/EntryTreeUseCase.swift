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
        throw UseCaseError.unimplement
    }
    
    public func listChildren() throws -> [any Entities.EntryInfo] {
        throw UseCaseError.unimplement
    }
    
    public func changeParent(entryID: Int64, newParentID: Int64) throws {
        throw UseCaseError.unimplement
    }
    
    public func deleteEntries(entrys: [Int64]) throws {
        throw UseCaseError.unimplement
    }
}
