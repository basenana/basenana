//
//  EntriesClientProtocol.swift
//
//
//  Created by Hypo on 2024/9/15.
//

import Foundation
import Domain
import Data
import Styleguide


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
    func SetProperties(entry: Int64, tags: [String]?, properties: [String: String]?) async throws
    func GetFridayProperty(uri: String) async throws -> String

    // document operations
    func FilterEntries(celPattern: String, page: Int?, pageSize: Int?, sort: String?, order: String?) async throws -> [any EntryInfo]
    func SearchEntries(query: String, page: Int?, pageSize: Int?) async throws -> [SearchResult]
    func UpdateDocumentByURI(uri: String, update: DocumentUpdate) async throws

    // group configs
    func GroupConfigs(uri: String) async throws -> GroupConfig
    func UpdateGroupConfig(uri: String, rss: RSSConfig?, filter: FilterConfig?) async throws -> GroupConfig
}


public protocol FileClientProtocol {
    func UploadFile(entry: Int64, fileHandle: FileHandle) async throws
    func DownloadFile(entry: Int64, file: String) async throws
}
