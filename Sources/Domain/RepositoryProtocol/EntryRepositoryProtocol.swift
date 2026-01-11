//
//  EntryRepositoryProtocol.swift
//
//
//  Created by Hypo on 2024/9/15.
//

import Foundation



public protocol EntryRepositoryProtocol {
    // entries
    func GroupTree() async throws -> EntryGroup
    func RootEntry() async throws -> EntryDetail
    func FindEntry(parentUri: String, name: String) async throws -> EntryDetail
    func GetEntryDetail(uri: String) async throws -> EntryDetail
    func CreateEntry(entry: EntryCreate) async throws -> EntryInfo
    func UpdateEntry(uri: String, name: String?) async throws -> EntryDetail
    func DeleteEntries(uris: [String]) async throws
    func ListGroupChildren(parentUri: String, page: Int?, pageSize: Int?, sort: String?, order: String?) async throws -> [EntryInfo]
    func ChangeParent(uri: String, newEntryUri: String, option: ChangeParentOption) async throws

    // entry properties
    func AddProperty(entry: Int64, key: String, val: String) async throws
    func UpdateProperty(entry: Int64, key: String, val: String) async throws
    func DeleteProperty(entry: Int64, key: String) async throws

    // document operations
    func ListDocuments(filter: DocumentFilter) async throws -> [EntryInfo]
    func UpdateDocument(uri: String, update: DocumentUpdate) async throws
}

