//
//  Store.swift
//  AppState
//
//  Created by Hypo on 2024/9/21.
//

import SwiftUI
import Observation


@Observable
public class StateStore {
    public static var shared = StateStore()

    public var notifications = [String]()
    public var backgroupJobs = [BackgroundJob]()
    public var fsInfo = FSInfo()
    public var setting = Setting.global

    // Global panel visibility states
    public var showInspector: Bool = false
    public var showDocumentView: Bool = false

    // Navigation state
    public var destinations: [Destination] = []

    // MARK: - Navigation Focus State
    public private(set) var _currentGroupUri: String? = nil
    public private(set) var _selectedEntryUri: String? = nil

    public var currentGroupUri: String? {
        get { _currentGroupUri }
        set {
            if _currentGroupUri != newValue {
                _currentGroupUri = newValue
                currentGroupUriDidChange?(newValue)
            }
        }
    }

    public var selectedEntryUri: String? {
        get { _selectedEntryUri }
        set {
            if _selectedEntryUri != newValue {
                _selectedEntryUri = newValue
                selectedEntryUriDidChange?(newValue)
            }
        }
    }

    // Callbacks for external binding
    public var currentGroupUriDidChange: ((String?) -> Void)?
    public var selectedEntryUriDidChange: ((String?) -> Void)?

    // MARK: - Tree State
    public private(set) var _treeChildren: [TreeNode] = []
    public private(set) var _treeAllGroups: [String: TreeNode] = [:]
    public private(set) var _rootGroup: EntryGroup?

    public var treeChildren: [TreeNode] {
        get { _treeChildren }
    }

    public var treeAllGroups: [String: TreeNode] {
        get { _treeAllGroups }
    }

    public var rootGroup: EntryGroup? {
        get { _rootGroup }
    }

    // MARK: - Tree Operations
    public func resetTree(root: EntryGroup) {
        _rootGroup = root
        _treeChildren = []
        _treeAllGroups = [:]

        guard let children = root.children else { return }

        for grp in children where !grp.groupName.hasPrefix(".") {
            let node = buildTreeNode(group: grp)
            _treeChildren.append(node)
        }
    }

    private func buildTreeNode(group: EntryGroup) -> TreeNode {
        let node = TreeNode(group: group)
        _treeAllGroups[node.uri] = node

        guard let children = group.children else { return node }

        if !children.isEmpty {
            node.children = []
            for grp in children where !grp.groupName.hasPrefix(".") {
                node.children?.append(buildTreeNode(group: grp))
            }
        }
        return node
    }

    public func addTreeChildGroup(parentUri: String, child: EntryGroup, grandChildren: [TreeNode]?) {
        let newNode = TreeNode(group: child, children: grandChildren)

        if let parent = _treeAllGroups[parentUri] {
            if parent.children == nil {
                parent.children = [newNode]
            } else {
                for (index, ch) in (parent.children ?? []).enumerated() {
                    if ch.name == child.groupName {
                        parent.children?[index] = newNode
                        _treeAllGroups[child.uri] = newNode
                        return
                    }
                }
                parent.children?.append(newNode)
            }
            _treeAllGroups[child.uri] = newNode
        } else {
            // Parent is root level
            _treeAllGroups[newNode.uri] = newNode
            _treeChildren.append(newNode)
        }
    }

    public func removeTreeChildGroup(parentUri: String, childUri: String) {
        guard _treeAllGroups[childUri] != nil else { return }

        if let parent = _treeAllGroups[parentUri] {
            parent.children = parent.children?.filter { $0.uri != childUri }
            if parent.children?.isEmpty ?? true {
                parent.children = nil
            }
        }
        _treeAllGroups[childUri] = nil
    }

    public func changeTreeParent(uri: String, newParentUri: String) {
        guard let node = _treeAllGroups[uri] else { return }

        if node.parentUri == newParentUri { return }

        // Prevent circular reference
        if isInLoop(uri: uri, newParentUri: newParentUri) { return }

        if let newParent = _treeAllGroups[newParentUri] {
            for exist in (newParent.children ?? []) {
                if exist.name == node.name { return }
            }
        }

        removeTreeChildGroup(parentUri: node.parentUri, childUri: uri)

        let movedNode = TreeNode(group: node.group, children: node.children)
        movedNode.updateName(node.name)

        if let newParent = _treeAllGroups[newParentUri] {
            if newParent.children == nil {
                newParent.children = [movedNode]
            } else {
                newParent.children?.append(movedNode)
            }
        } else {
            _treeChildren.append(movedNode)
        }

        _treeAllGroups[newParentUri + "/" + node.name] = movedNode
        _treeAllGroups[uri] = nil

        updateDescendantUris(node: movedNode, oldParentUri: uri, newParentUri: newParentUri)
    }

    /// Update descendant URIs after parent change
    private func updateDescendantUris(node: TreeNode, oldParentUri: String, newParentUri: String) {
        guard let children = node.children else { return }

        for child in children {
            let oldChildUri = child.uri
            let newChildUri = newParentUri + "/" + child.name

            _treeAllGroups[newChildUri] = child
            _treeAllGroups[oldChildUri] = nil

            updateDescendantUris(node: child, oldParentUri: oldChildUri, newParentUri: newChildUri)
        }
    }

    private func isInLoop(uri: String, newParentUri: String) -> Bool {
        var nextUri = newParentUri
        while let parent = _treeAllGroups[nextUri] {
            if parent.uri == uri { return true }
            nextUri = parent.parentUri
        }
        return false
    }

    public func getTreeGroup(uri: String) -> TreeNode? {
        _treeAllGroups[uri]
    }

    /// Get all visible groups as a flat list for parent selection
    /// - Returns: Array of (uri, name, indentLevel) tuples
    public func getVisibleGroupsForParentSelection() -> [(uri: String, name: String, indent: Int)] {
        var result: [(uri: String, name: String, indent: Int)] = []

        // Add root option
        result.append((uri: "/", name: "Root", indent: 0))

        // Recursively add visible groups
        addVisibleGroups(from: _treeChildren, indent: 0, into: &result)

        return result
    }

    private func addVisibleGroups(from nodes: [TreeNode], indent: Int, into result: inout [(uri: String, name: String, indent: Int)]) {
        for node in nodes {
            result.append((uri: node.uri, name: node.name, indent: indent))
            if let children = node.children, !children.isEmpty {
                addVisibleGroups(from: children, indent: indent + 1, into: &result)
            }
        }
    }

    // MARK: - Tree Node Update Operations

    /// Update node name and URI after rename
    public func updateTreeNode(uri: String, newName: String, newUri: String) {
        guard let node = _treeAllGroups[uri] else { return }

        let nodeChildren = node.children

        let newNode = TreeNode(group: node.group, children: nodeChildren)
        newNode.updateName(newName)

        if let children = newNode.children {
            for child in children {
                updateDescendantUrisForRename(node: child, oldBaseUri: uri, newBaseUri: newUri)
            }
        }

        _treeAllGroups[newUri] = newNode
        _treeAllGroups[uri] = nil

        if node.parentUri != "/" && node.parentUri != "" {
            if let parentNode = _treeAllGroups[node.parentUri] {
                if let index = parentNode.children?.firstIndex(where: { $0.uri == uri }) {
                    parentNode.children?[index] = newNode
                }
            }
        } else {
            if let index = _treeChildren.firstIndex(where: { $0.uri == uri }) {
                _treeChildren[index] = newNode
            }
        }
    }

    /// Update descendant URIs after rename
    private func updateDescendantUrisForRename(node: TreeNode, oldBaseUri: String, newBaseUri: String) {
        let oldUri = node.uri
        let newUri = newBaseUri + "/" + node.name

        _treeAllGroups[newUri] = node
        _treeAllGroups[oldUri] = nil

        if let children = node.children {
            for child in children {
                updateDescendantUrisForRename(node: child, oldBaseUri: oldUri, newBaseUri: newUri)
            }
        }
    }

    private init(){ }
}

// MARK: - Environment Key for StateStore
struct StateStoreKey: EnvironmentKey {
    public static let defaultValue: StateStore? = nil
}

extension EnvironmentValues {
    public var stateStore: StateStore? {
        get { self[StateStoreKey.self] }
        set { self[StateStoreKey.self] = newValue }
    }
}


public class FSInfo: Equatable {
    public var fsApiReady = false

    public init() {}

    public static func == (lhs: FSInfo, rhs: FSInfo) -> Bool {
        return lhs.fsApiReady == rhs.fsApiReady
    }
}
