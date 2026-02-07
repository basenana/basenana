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

    // MARK: - Children Cache (使用 CachedEntry 类型)
    public private(set) var _childrenList: [CachedEntry] = []

    public var childrenList: [CachedEntry] {
        get { _childrenList }
    }

    // MARK: - Children Cache Operations
    public func appendChildren(_ items: [CachedEntry]) {
        _childrenList.append(contentsOf: items)
    }

    public func removeChildren(uris: [String]) {
        _childrenList.removeAll { uris.contains($0.uri) }
    }

    public func resetChildren() {
        _childrenList = []
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

        // 防止循环引用：不能将父节点移动到其子节点中
        if isInLoop(uri: uri, newParentUri: newParentUri) { return }

        if let newParent = _treeAllGroups[newParentUri] {
            for exist in (newParent.children ?? []) {
                if exist.name == node.name { return }
            }
        }

        removeTreeChildGroup(parentUri: node.parentUri, childUri: uri)
        addTreeChildGroup(parentUri: newParentUri, child: node.group, grandChildren: node.children)
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
