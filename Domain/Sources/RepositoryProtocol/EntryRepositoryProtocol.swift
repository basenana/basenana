//
//  EntryRepositoryProtocol.swift
//
//
//  Created by Hypo on 2024/9/15.
//

import Foundation
import Entities


protocol EntryRepositoryProtocol {
    // entries
    func GroupTree() throws -> Group
    func RootEntry() throws -> EntryDetail
    func FindEntry(parent: Int64, name: String) throws -> EntryDetail
    func GetEntryDetail(entry: Int64) throws -> EntryDetail
    func CreateEntry(entry: EntryCreate) throws -> EntryInfo
    func UpdateEntry(entry: EntryUpdate) throws -> EntryDetail
    func DeleteEntries(entrys: [Int64]) throws
    func ListGroupChildren(parent: Int64) throws -> [EntryInfo]
    func ChangeParent() throws
    
    // entry properties
    func AddProperty(entry: Int64, key: String, val: String) throws
    func UpdateProperty(entry: Int64, key: String, val: String) throws
    func DeleteProperty(entry: Int64, key: String) throws
}

