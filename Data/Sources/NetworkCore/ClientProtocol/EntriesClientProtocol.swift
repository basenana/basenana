//
//  EntriesClientProtocol.swift
//
//
//  Created by Hypo on 2024/9/15.
//

import Foundation
import Entities


public protocol EntriesClientProtocol {
    // entries
    func GroupTree() throws -> Group
    func RootEntry() throws -> APIEntryDetail
    func FindEntry(parent: Int64, name: String) throws -> APIEntryDetail
    func GetEntryDetail(entry: Int64) throws -> APIEntryDetail
    func CreateEntry(entry: EntryCreate) throws -> APIEntryInfo
    func UpdateEntry(entry: EntryUpdate) throws -> APIEntryDetail
    func DeleteEntries(entrys: [Int64]) throws
    func ListGroupChildren(parent: Int64) throws -> [APIEntryInfo]
    func ChangeParent(entry: Int64, newParent: Int64, option: ChangeParentOption) throws
    
    // entry properties
    func AddProperty(entry: Int64, key: String, val: String) throws
    func UpdateProperty(entry: Int64, key: String, val: String) throws
    func DeleteProperty(entry: Int64, key: String) throws
}


public protocol FileClientProtocol {
    func WriteFile(entry: Int64, off: Int64, len: Int64, input: Stream) throws
    func ReadFile(entry: Int64, off: Int64, len: Int64) throws -> Stream
}
