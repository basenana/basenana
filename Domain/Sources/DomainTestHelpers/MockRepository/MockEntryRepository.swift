//
//  MockEntryRepository.swift
//  Entry
//
//  Created by Hypo on 2024/9/22.
//

import SwiftUI
import Entities
import RepositoryProtocol

var entiesForTest: [MockEntryDetail] = [
    .init(id: 1, name: "root", aliases: "", parent: 1, kind: "Group", isGroup: true, size: 0, version: 0, namespace: "default", storage: "default", uid: 0, gid: 0, permissions: [], createdAt: Date(), changedAt: Date(), modifiedAt: Date(), accessAt: Date(), properties: []),
    .init(id: 1010, name: "group1", aliases: "", parent: 1, kind: "Group", isGroup: true, size: 0, version: 0, namespace: "default", storage: "default", uid: 0, gid: 0, permissions: [], createdAt: Date(), changedAt: Date(), modifiedAt: Date(), accessAt: Date(), properties: []),
    .init(id: 1011, name: "group1.1", aliases: "", parent: 1010, kind: "Group", isGroup: true, size: 0, version: 0, namespace: "default", storage: "default", uid: 0, gid: 0, permissions: [], createdAt: Date(), changedAt: Date(), modifiedAt: Date(), accessAt: Date(), properties: []),
    .init(id: 1012, name: "group1.2", aliases: "", parent: 1010, kind: "Group", isGroup: true, size: 0, version: 0, namespace: "default", storage: "default", uid: 0, gid: 0, permissions: [], createdAt: Date(), changedAt: Date(), modifiedAt: Date(), accessAt: Date(), properties: []),
    .init(id: 1013, name: "file1.3", aliases: "", parent: 1010, kind: "Group", isGroup: false, size: 0, version: 0, namespace: "default", storage: "default", uid: 0, gid: 0, permissions: [], createdAt: Date(), changedAt: Date(), modifiedAt: Date(), accessAt: Date(), properties: []),
    .init(id: 1020, name: "group2", aliases: "", parent: 1, kind: "Group", isGroup: true, size: 0, version: 0, namespace: "default", storage: "default", uid: 0, gid: 0, permissions: [], createdAt: Date(), changedAt: Date(), modifiedAt: Date(), accessAt: Date(), properties: []),
    .init(id: 1021, name: "group2.1", aliases: "", parent: 1020, kind: "Group", isGroup: true, size: 0, version: 0, namespace: "default", storage: "default", uid: 0, gid: 0, permissions: [], createdAt: Date(), changedAt: Date(), modifiedAt: Date(), accessAt: Date(), properties: []),
    .init(id: 1022, name: "group2.2", aliases: "", parent: 1020, kind: "Group", isGroup: true, size: 0, version: 0, namespace: "default", storage: "default", uid: 0, gid: 0, permissions: [], createdAt: Date(), changedAt: Date(), modifiedAt: Date(), accessAt: Date(), properties: []),
    .init(id: 1023, name: "file2.3", aliases: "", parent: 1020, kind: "Group", isGroup: false, size: 0, version: 0, namespace: "default", storage: "default", uid: 0, gid: 0, permissions: [], createdAt: Date(), changedAt: Date(), modifiedAt: Date(), accessAt: Date(), properties: []),
]


public class MockEntryRepository: EntryRepositoryProtocol {
    
    public static var shared = MockEntryRepository(data: entiesForTest)
    
    private var repo: [Int64:MockEntryDetail] = [:]
    private var groups: [Int64:[Int64]] = [:]
    
    init(data: [MockEntryDetail]) {
        for en in data {
            self.repo[en.id] = en
            if self.groups[en.parent] == nil {
                self.groups[en.parent] = []
            }
            self.groups[en.parent]!.append(en.id)
        }
    }
    
    public func GroupTree() throws -> any Entities.Group {
        let root = MockGroup(id: 1, groupName: "root", parentID: 1, children: [])
        let children = try ListGroupChildren(filter: EntryFilter(parent: 1))
        
        for ch in children {
            if !ch.isGroup || ch.id == 1 {
                continue
            }
            root.children!.append(try buildTree(grp: ch.id))
        }
        return root
    }
    
    func buildTree(grp: Int64) throws -> MockGroup {
        let en = try GetEntryDetail(entry: grp)
        let result = MockGroup(id: en.id, groupName: en.name, parentID: en.parent)
        
        let children = try ListGroupChildren(filter: EntryFilter(parent: grp))
        if children.isEmpty {
            return result
        }

        result.children = []
        for ch in children {
            if !ch.isGroup {
                continue
            }
            result.children!.append(try buildTree(grp: ch.id))
        }
        return result
    }

    public func RootEntry() throws -> any Entities.EntryDetail {
        return try GetEntryDetail(entry: 1)
    }
    
    public func FindEntry(parent: Int64, name: String) throws -> any Entities.EntryDetail {
        for kv in self.repo {
            let en = kv.value
            if en.parent == parent && en.name == name {
                return en
            }
        }
        throw RepositoryError.notFound
    }
    
    public func GetEntryDetail(entry: Int64) throws -> any Entities.EntryDetail {
        guard let en = repo[entry] else {
            throw RepositoryError.notFound
        }
        return en
    }
    
    public func CreateEntry(entry: Entities.EntryCreate) throws -> any Entities.EntryInfo {
        throw RepositoryError.unimplement
    }
    
    public func UpdateEntry(entry: Entities.EntryUpdate) throws -> any Entities.EntryDetail {
        let en = try GetEntryDetail(entry: entry.id)
        return en
    }
    
    public func DeleteEntries(entrys: [Int64]) throws {
        for entry in entrys {
            guard let en = self.repo.removeValue(forKey: entry) else {
                continue
            }
            self.groups[en.parent] = self.groups[en.parent]!.filter({ $0 != entry })
        }
    }
    
    public func ListGroupChildren(filter: Entities.EntryFilter) throws -> [any Entities.EntryInfo] {
        var result: [MockEntryInfo] = []
        guard let entryIDs = self.groups[filter.parent] else {
            return result
        }
        
        for entry in entryIDs {
            result.append(self.repo[entry]!.toInfo())
        }
        
        return result
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
