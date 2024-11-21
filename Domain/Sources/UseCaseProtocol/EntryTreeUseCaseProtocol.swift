//
//  EntryTreeUseCaseProtocol.swift
//
//
//  Created by Hypo on 2024/9/13.
//

import Foundation
import Entities


public protocol EntryTreeUseCaseProtocol {
    func getTreeRoot() throws -> Group
    func listChildren(entry: Int64) throws -> [EntryInfo]
    func changeParent(entry: Int64, newParent: Int64) throws
    func deleteEntries(entries: [Int64]) throws
}
