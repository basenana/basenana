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
    func listChildren() throws -> [EntryInfo]
    func changeParent(entryID: Int64, newParentID: Int64) throws
    func deleteEntries(entrys: [Int64]) throws
}
