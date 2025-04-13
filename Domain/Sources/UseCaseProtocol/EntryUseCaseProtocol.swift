//
//  EntryUseCaseProtocol.swift
//
//
//  Created by Hypo on 2024/9/13.
//

import Foundation
import Entities


public protocol EntryUseCaseProtocol {
    func getEntryDetails(entry: Int64) async throws -> EntryDetail
    func renameEntry(entry: Int64, newName: String) async throws
    func deleteEntry(entry: Int64) async throws
    func deleteEntries(entries: [Int64]) async throws

    func getTreeRoot() async throws -> Group
    func listChildren(entry: Int64) async throws -> [EntryInfo]
    func changeParent(entries: [Int64], newParent: Int64, finisher: @escaping (EntryDetail, EntryDetail) -> Void) async throws
    func createGroups(parent: Int64, option: EntryCreate) async throws -> EntryInfo
    
    func UploadFile(parent: Int64, file: URL, properties: [String:String]) async throws -> EntryInfo
    func DownloadFile(entry: Int64, dirPath: String) async throws -> String
}
