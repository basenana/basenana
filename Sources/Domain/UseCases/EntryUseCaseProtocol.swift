//
//  EntryUseCaseProtocol.swift
//
//
//  Created by Hypo on 2024/9/13.
//

import Foundation



public protocol EntryUseCaseProtocol {
    func getEntryDetails(uri: String) async throws -> EntryDetail
    func renameEntry(uri: String, newName: String) async throws
    func deleteEntry(uri: String) async throws
    func deleteEntries(uris: [String]) async throws

    func getTreeRoot() async throws -> EntryGroup
    func listChildren(uri: String) async throws -> [EntryInfo]
    func changeParent(uris: [String], newParentUri: String, finisher: @escaping (EntryDetail, EntryDetail) -> Void) async throws
    func createGroups(parentUri: String, option: EntryCreate) async throws -> EntryInfo

    func UploadFile(parent: Int64, file: URL, properties: [String:String]) async throws -> EntryInfo
    func DownloadFile(entry: Int64, dirPath: String) async throws -> String
}
