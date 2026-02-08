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

    public func syncChildrenAfterMove(uris: [String], fromParent: String, toParent: String, currentGroupUri: String?) {
        // Notify that children changed in the source parent
        NotificationCenter.default.post(
            name: .childrenChanged,
            object: ChildrenChange(parentUri: fromParent, changeType: .move)
        )

        // Notify that children changed in the destination parent
        NotificationCenter.default.post(
            name: .childrenChanged,
            object: ChildrenChange(parentUri: toParent, changeType: .create)
        )

        // Notify that children changed in the moved groups themselves
        // This is needed when the currently opened group was moved - it needs to refresh its children
        for uri in uris {
            NotificationCenter.default.post(
                name: .childrenChanged,
                object: ChildrenChange(parentUri: uri, changeType: .move)
            )
        }

        // Detect if the currently opened group was moved
        guard let currentUri = currentGroupUri else { return }

        for uri in uris {
            let calculatedNewUri = newUri(for: uri, from: fromParent, to: toParent, currentGroupUri: currentGroupUri)
            // Only reopen if the moved URI matches the current opened group exactly
            if currentUri == uri && calculatedNewUri != nil {
                // Send notification so views can update to the new URI
                NotificationCenter.default.post(name: Notification.Name("reopenGroup"), object: [uri, calculatedNewUri!])
            }
        }
    }

    private func newUri(for uri: String, from: String, to: String, currentGroupUri: String? = nil) -> String? {
        guard uri.hasPrefix(from) else { return nil }

        let suffix = String(uri.dropFirst(from.count))

        // Only valid if suffix starts with "/" (direct child) or is empty (moving the folder itself)
        // Otherwise, from is just a path prefix, not the direct parent
        if !suffix.isEmpty && !suffix.hasPrefix("/") {
            return nil
        }

        // Prevent moving a parent folder into its own descendant's path
        // e.g., currentGroupUri = "/A/B", moving "/A" to "/A/B/X" should not trigger reopen
        if let current = currentGroupUri, !current.isEmpty {
            let potentialNewUri = (to.isEmpty ? "" : to) + suffix
            if current.hasPrefix(potentialNewUri) && current != potentialNewUri {
                return nil
            }
        }

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
