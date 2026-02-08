//
//  EntrySyncUseCaseProtocol.swift
//  Domain
//
//  Created by Hypo on 2025/2/8.
//

import Foundation

/// Cache synchronization protocol for Entry operations
public protocol EntrySyncUseCaseProtocol {

    // MARK: - Tree Operations

    func syncTreeAfterCreate(parentUri: String, group: EntryGroup)
    func syncTreeAfterDelete(uris: [String])
    func syncTreeAfterMove(uri: String, newParentUri: String)
    func syncTreeAfterRename(uri: String, newName: String, newUri: String)

    // MARK: - Children Operations

    func syncChildrenAfterCreate(parentUri: String, entries: [EntryInfo])
    func syncChildrenAfterCreate(parentUri: String, entry: EntryInfo)
    func syncChildrenAfterDelete(parentUri: String?, uris: [String])
    func syncChildrenAfterMove(uris: [String], fromParent: String, toParent: String)
    func syncChildrenAfterRename(id: Int64, newName: String, newUri: String)

    // MARK: - Full Reset

    func resetTree(root: EntryGroup)
    func resetChildren()
}
