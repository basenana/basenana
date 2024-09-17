//
//  EntriesClient.swift
//
//
//  Created by Hypo on 2024/9/16.
//

import Foundation
import Entities
import NetworkCore


public class EntriesClient: EntriesClientProtocol {
    
    var client: Api_V1_EntriesClientProtocol
    
    init(client: Api_V1_EntriesClientProtocol) {
        self.client = client
    }
    
    public func GroupTree() throws -> any Entities.Group {
        throw RepositoryError.unimplement
    }
    
    public func RootEntry() throws -> NetworkCore.APIEntryDetail {
        throw RepositoryError.unimplement
    }
    
    public func FindEntry(parent: Int64, name: String) throws -> NetworkCore.APIEntryDetail {
        throw RepositoryError.unimplement
    }
    
    public func GetEntryDetail(entry: Int64) throws -> NetworkCore.APIEntryDetail {
        throw RepositoryError.unimplement
    }
    
    public func CreateEntry(entry: Entities.EntryCreate) throws -> NetworkCore.APIEntryInfo {
        throw RepositoryError.unimplement
    }
    
    public func UpdateEntry(entry: Entities.EntryUpdate) throws -> NetworkCore.APIEntryDetail {
        throw RepositoryError.unimplement
    }
    
    public func DeleteEntries(entrys: [Int64]) throws {
        throw RepositoryError.unimplement
    }
    
    public func ListGroupChildren(parent: Int64) throws -> [NetworkCore.APIEntryInfo] {
        throw RepositoryError.unimplement
    }
    
    public func ChangeParent(entry: Int64, newParent: Int64, option: Entities.ChangeParentOption) throws {
        throw RepositoryError.unimplement
    }
    
    public func AddProperty(entry: Int64, key: String, val: String) throws {
        throw RepositoryError.unimplement
    }
    
    public func UpdateProperty(entry: Int64, key: String, val: String) throws {
        throw RepositoryError.unimplement
    }
    
    public func DeleteProperty(entry: Int64, key: String) throws {
        throw RepositoryError.unimplement
    }
    
    
}
