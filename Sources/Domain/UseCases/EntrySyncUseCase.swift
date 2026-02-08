//
//  EntrySyncUseCase.swift
//  Domain
//
//  Created by Hypo on 2025/2/8.
//

import Foundation

/// Unified cache synchronization for Entry operations
public final class EntrySyncUseCase: EntrySyncUseCaseProtocol {

    private let store: StateStore

    public init(store: StateStore = .shared) {
        self.store = store
    }

    // MARK: - Tree Operations

    public func syncTreeAfterCreate(parentUri: String, group: EntryGroup) {
        store.addTreeChildGroup(parentUri: parentUri, child: group, grandChildren: nil)
    }

    public func syncTreeAfterDelete(uris: [String]) {
        for uri in uris {
            if let node = store.getTreeGroup(uri: uri) {
                store.removeTreeChildGroup(parentUri: node.parentUri, childUri: uri)
            }
        }
    }

    public func syncTreeAfterMove(uri: String, newParentUri: String) {
        if let node = store.getTreeGroup(uri: uri) {
            store.changeTreeParent(uri: uri, newParentUri: newParentUri)
        }
    }

    public func syncTreeAfterRename(uri: String, newName: String, newUri: String) {
        store.updateTreeNode(uri: uri, newName: newName, newUri: newUri)
    }

    // MARK: - Children Operations

    public func syncChildrenAfterCreate(parentUri: String, entries: [EntryInfo]) {
        guard store.currentGroupUri == parentUri else { return }
        let cachedEntries = entries.map { CachedEntry(from: $0) }
        store.appendChildren(cachedEntries)
    }

    public func syncChildrenAfterCreate(parentUri: String, entry: EntryInfo) {
        syncChildrenAfterCreate(parentUri: parentUri, entries: [entry])
    }

    public func syncChildrenAfterDelete(parentUri: String?, uris: [String]) {
        if let parent = parentUri, store.currentGroupUri != parent { return }
        store.removeChildrenRecursively(uris: uris)
    }

    public func syncChildrenAfterMove(uris: [String], fromParent: String, toParent: String) {
        if store.currentGroupUri == fromParent {
            store.removeChildrenRecursively(uris: uris)
        }
    }

    public func syncChildrenAfterRename(id: Int64, newName: String, newUri: String) {
        store.updateCachedEntry(id: id, newName: newName, newUri: newUri)
    }

    // MARK: - Full Reset

    public func resetTree(root: EntryGroup) {
        store.resetTree(root: root)
    }

    public func resetChildren() {
        store.resetChildren()
    }
}
