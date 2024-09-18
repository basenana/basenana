//
//  EntryRepository.swift
//
//
//  Created by Hypo on 2024/9/15.
//

import Foundation
import Entities
import NetworkCore
import RepositoryProtocol


public class EntryRepository: EntryRepositoryProtocol {
    
    private var core: EntriesClientProtocol
    
    init(core: EntriesClientProtocol) {
        self.core = core
    }
    
    public func GroupTree() throws -> any Entities.Group {
        return try core.GroupTree()
    }
    
    public func RootEntry() throws -> any Entities.EntryDetail {
        return try core.RootEntry()
    }
    
    public func FindEntry(parent: Int64, name: String) throws -> any Entities.EntryDetail {
        return try core.FindEntry(parent: parent, name: name)
    }
    
    public func GetEntryDetail(entry: Int64) throws -> any Entities.EntryDetail {
        return try core.GetEntryDetail(entry: entry)
    }
    
    public func CreateEntry(entry: Entities.EntryCreate) throws -> any Entities.EntryInfo {
        return try core.CreateEntry(entry: entry)
    }
    
    public func UpdateEntry(entry: Entities.EntryUpdate) throws -> any Entities.EntryDetail {
        return try core.UpdateEntry(entry: entry)
    }
    
    public func DeleteEntries(entrys: [Int64]) throws {
        return try core.DeleteEntries(entrys: entrys)
    }
    
    public func ListGroupChildren(filter: EntryFilter) throws -> [any Entities.EntryInfo] {
        return try core.ListGroupChildren(filter: filter)
    }
    
    public func ChangeParent(entry: Int64, newParent: Int64, option: ChangeParentOption) throws {
        return try core.ChangeParent(entry: entry, newParent: newParent, option: option)
    }
    
    public func AddProperty(entry: Int64, key: String, val: String) throws {
        return try core.AddProperty(entry: entry, key: key, val: val)
    }
    
    public func UpdateProperty(entry: Int64, key: String, val: String) throws {
        return try core.UpdateProperty(entry: entry, key: key, val: val)
    }
    
    public func DeleteProperty(entry: Int64, key: String) throws {
        return try core.DeleteProperty(entry: entry, key: key)
    }
    
}

