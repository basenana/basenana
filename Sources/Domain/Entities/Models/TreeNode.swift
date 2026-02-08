//
//  TreeNode.swift
//  AppState
//
//  Created by Hypo on 2025/2/7.
//

import Foundation

/// 树节点 (从 Feature 层迁移到 Domain 层)
public final class TreeNode: Identifiable, Hashable {
    public let id: String
    public let uri: String
    public private(set) var name: String
    public let parentUri: String
    public var group: EntryGroup
    public var children: [TreeNode]?

    // 别名: 兼容 GroupLeaf 的 groupName
    public var groupName: String { name }

    // 用于 KeyPath 兼容
    public static let childrenKeyPath: KeyPath<TreeNode, [TreeNode]?> = \.children

    public init(group: EntryGroup, children: [TreeNode]? = nil) {
        self.group = group
        self.id = group.uri
        self.uri = group.uri
        self.name = group.groupName
        self.children = children

        // 计算 parentUri
        let components = uri.split(separator: "/")
        if components.count > 1 {
            self.parentUri = "/" + components.dropLast().joined(separator: "/")
        } else {
            self.parentUri = ""
        }
    }

    /// 更新显示名称（用于重命名场景）
    public func updateName(_ newName: String) {
        name = newName
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    public static func == (lhs: TreeNode, rhs: TreeNode) -> Bool {
        lhs.id == rhs.id
    }
}
