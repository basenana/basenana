//
//  EntrySyncUseCase.swift
//  Domain
//
//  Created by Hypo on 2025/2/8.
//

import Foundation

/// Notification names for children cache sync
public extension Notification.Name {
    static let childrenChanged = Notification.Name("childrenChanged")
}

/// Payload for childrenChanged notification
public struct ChildrenChange {
    public var parentUri: String
    public var changeType: ChangeType

    public enum ChangeType {
        case create
        case delete
        case move
        case rename
    }

    public init(parentUri: String, changeType: ChangeType) {
        self.parentUri = parentUri
        self.changeType = changeType
    }
}

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
        NotificationCenter.default.post(
            name: .childrenChanged,
            object: ChildrenChange(parentUri: parentUri, changeType: .create)
        )
    }

    public func syncChildrenAfterCreate(parentUri: String, entry: EntryInfo) {
        syncChildrenAfterCreate(parentUri: parentUri, entries: [entry])
    }

    public func syncChildrenAfterDelete(parentUri: String?, uris: [String]) {
        NotificationCenter.default.post(
            name: .childrenChanged,
            object: ChildrenChange(parentUri: parentUri ?? "", changeType: .delete)
        )
    }

    public func syncChildrenAfterMove(uris: [String], fromParent: String, toParent: String) {
        // Notify that children changed in the source parent
        NotificationCenter.default.post(
            name: .childrenChanged,
            object: ChildrenChange(parentUri: fromParent, changeType: .move)
        )

        // Detect if the currently opened group was moved
        for uri in uris {
            let newUri = newUri(for: uri, from: fromParent, to: toParent)
            if store.currentGroupUri == uri && newUri != nil {
                // Update store first, then notify with OLD uri so views can identify themselves
                let oldUri = store.currentGroupUri
                store.currentGroupUri = newUri!
                // Send old URI so views can match and update to new URI
                NotificationCenter.default.post(name: Notification.Name("reopenGroup"), object: [oldUri, newUri!])
            }
        }
    }

    private func newUri(for uri: String, from: String, to: String) -> String? {
        guard uri.hasPrefix(from) else { return nil }
        let suffix = String(uri.dropFirst(from.count))
        let newParent = to.isEmpty ? "" : to
        return newParent + suffix
    }

    public func syncChildrenAfterRename(id: Int64, newName: String, newUri: String) {
        NotificationCenter.default.post(
            name: .childrenChanged,
            object: ChildrenChange(parentUri: "", changeType: .rename)
        )
    }

    // MARK: - Full Reset

    public func resetTree(root: EntryGroup) {
        store.resetTree(root: root)
    }

    public func resetChildren() {
        NotificationCenter.default.post(
            name: .childrenChanged,
            object: ChildrenChange(parentUri: "", changeType: .delete)
        )
    }
}
