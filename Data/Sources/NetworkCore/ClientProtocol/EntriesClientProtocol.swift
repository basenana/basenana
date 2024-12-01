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
    func GroupTree() async throws -> Group
    func RootEntry() async throws -> APIEntryDetail
    func FindEntry(parent: Int64, name: String) async throws -> APIEntryDetail
    func GetEntryDetail(entry: Int64) async throws -> APIEntryDetail
    func CreateEntry(entry: EntryCreate) async throws -> APIEntryInfo
    func UpdateEntry(entry: EntryUpdate) async throws -> APIEntryDetail
    func DeleteEntries(entrys: [Int64]) async throws
    func ListGroupChildren(filter: EntryFilter) async throws -> [APIEntryInfo]
    func ChangeParent(entry: Int64, newParent: Int64, option: ChangeParentOption) async throws
    
    // entry properties
    func AddProperty(entry: Int64, key: String, val: String) async throws
    func UpdateProperty(entry: Int64, key: String, val: String) async throws
    func DeleteProperty(entry: Int64, key: String) async throws
}


public protocol FileClientProtocol {
    func UploadFile(entry: Int64, fileHandle: FileHandle) async throws
    func DownloadFile(entry: Int64, file: String) async throws
}
