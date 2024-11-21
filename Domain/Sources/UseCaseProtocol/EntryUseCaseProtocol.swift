//
//  EntryUseCaseProtocol.swift
//
//
//  Created by Hypo on 2024/9/13.
//

import Foundation
import Entities


public protocol EntryUseCaseProtocol {
    func getEntryDetails(entry: Int64) throws -> EntryDetail
    func renameEntry(entry: Int64, newName: String) throws
    func deleteEntry(entry: Int64) throws
}
