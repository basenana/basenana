//
//  EntryRepository.swift
//
//
//  Created by Hypo on 2024/9/15.
//

import Foundation
import Domain
import Data
import Domain


public class EntryRepository: EntryRepositoryProtocol {
    
    private var core: EntriesClientProtocol
    
    public init(core: EntriesClientProtocol) {
        self.core = core
    }
    
    public func GroupTree() async throws -> any EntryGroup {
        return try await core.GroupTree()
    }
    
    public func RootEntry() async throws -> any EntryDetail {
        return try await core.RootEntry()
    }
    
    public func FindEntry(parent: Int64, name: String) async throws -> any EntryDetail {
        return try await core.FindEntry(parent: parent, name: name)
    }
    
    public func GetEntryDetail(entry: Int64) async throws -> any EntryDetail {
        return try await core.GetEntryDetail(entry: entry)
    }
    
    public func CreateEntry(entry: EntryCreate) async throws -> any EntryInfo {
        return try await core.CreateEntry(entry: entry)
    }
    
    public func UpdateEntry(entry: EntryUpdate) async throws -> any EntryDetail {
        return try await core.UpdateEntry(entry: entry)
    }
    
    public func DeleteEntries(entrys: [Int64]) async throws {
        return try await core.DeleteEntries(entrys: entrys)
    }
    
    public func ListGroupChildren(filter: EntryFilter) async throws -> [any EntryInfo] {
        return try await core.ListGroupChildren(filter: filter)
    }
    
    public func ChangeParent(entry: Int64, newParent: Int64, option: ChangeParentOption) async throws {
        return try await core.ChangeParent(entry: entry, newParent: newParent, option: option)
    }
    
    public func AddProperty(entry: Int64, key: String, val: String) async throws {
        return try await core.AddProperty(entry: entry, key: key, val: val)
    }
    
    public func UpdateProperty(entry: Int64, key: String, val: String) async throws {
        return try await core.UpdateProperty(entry: entry, key: key, val: val)
    }
    
    public func DeleteProperty(entry: Int64, key: String) async throws {
        return try await core.DeleteProperty(entry: entry, key: key)
    }
    
}

