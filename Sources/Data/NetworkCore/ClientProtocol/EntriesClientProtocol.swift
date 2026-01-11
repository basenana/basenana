//
//  EntriesClientProtocol.swift
//
//
//  Created by Hypo on 2024/9/15.
//

import Foundation
import Domain
import Data


public protocol EntriesClientProtocol {
    // entries
    func GroupTree() async throws -> EntryGroup
    func RootEntry() async throws -> APIEntryDetail
    func FindEntry(parentUri: String, name: String) async throws -> APIEntryDetail
    func GetEntryDetail(uri: String) async throws -> APIEntryDetail
    func CreateEntry(entry: EntryCreate) async throws -> APIEntryInfo
    func UpdateEntry(uri: String, name: String?) async throws -> APIEntryDetail
    func DeleteEntries(uris: [String]) async throws
    func ListGroupChildren(parentUri: String, page: Int?, pageSize: Int?, sort: String?, order: String?) async throws -> [any EntryInfo]
    func ChangeParent(uri: String, newEntryUri: String, option: ChangeParentOption) async throws

    // entry properties
    func AddProperty(entry: Int64, key: String, val: String) async throws
    func UpdateProperty(entry: Int64, key: String, val: String) async throws
    func DeleteProperty(entry: Int64, key: String) async throws

    // document operations
    func SearchEntries(celPattern: String, page: Int?, pageSize: Int?, sort: String?, order: String?) async throws -> [any EntryInfo]
    func UpdateDocumentByURI(uri: String, update: DocumentUpdate) async throws
}


public protocol FileClientProtocol {
    func UploadFile(entry: Int64, fileHandle: FileHandle) async throws
    func DownloadFile(entry: Int64, file: String) async throws
}
