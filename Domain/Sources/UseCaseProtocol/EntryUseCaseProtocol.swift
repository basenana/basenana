//
//  EntryUseCaseProtocol.swift
//
//
//  Created by Hypo on 2024/9/13.
//

import Foundation
import Entities


public protocol EntryUseCaseProtocol {
    func quickInbox(url: String, fileName: String, fileType: FileType) throws
    
    func getEntryDetails(entry: Int64) throws -> EntryDetail
    func renameEntry(entry: Int64, newName: String) throws
    func deleteEntry(entry: Int64) throws
    func deleteEntries(entries: [Int64]) throws

    func getTreeRoot() throws -> Group
    func listChildren(entry: Int64) throws -> [EntryInfo]
    func changeParent(entry: Int64, newParent: Int64) throws
    func createGroups(parent: Int64, option: EntryCreate) throws -> EntryInfo
}
