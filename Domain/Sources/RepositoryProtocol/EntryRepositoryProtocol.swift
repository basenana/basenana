//
//  EntryRepositoryProtocol.swift
//
//
//  Created by Hypo on 2024/9/15.
//

import Foundation
import Entities


public protocol EntryRepositoryProtocol {
    // entries
    func GroupTree() async throws -> Group
    func RootEntry() async throws -> EntryDetail
    func FindEntry(parent: Int64, name: String) async throws -> EntryDetail
    func GetEntryDetail(entry: Int64) async throws -> EntryDetail
    func CreateEntry(entry: EntryCreate) async throws -> EntryInfo
    func UpdateEntry(entry: EntryUpdate) async throws -> EntryDetail
    func DeleteEntries(entrys: [Int64]) async throws
    func ListGroupChildren(filter: EntryFilter) async throws -> [EntryInfo]
    func ChangeParent(entry: Int64, newParent: Int64, option: ChangeParentOption) async throws
    
    // entry properties
    func AddProperty(entry: Int64, key: String, val: String) async throws
    func UpdateProperty(entry: Int64, key: String, val: String) async throws
    func DeleteProperty(entry: Int64, key: String) async throws
}

