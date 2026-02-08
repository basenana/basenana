//
//  TrewViewModel.swift
//  Entry
//
//  Created by Hypo on 2024/9/22.
//

import os
import SwiftUI
import Domain
import Domain
import Domain


@Observable
@MainActor
public class TreeViewModel: BaseViewModel {

    var selectedGroupUri: String? = nil

    /// Tracks expanded node URIs (used to preserve expanded state)
    private var expandedNodes: Set<String> = []

    private static let logger = Logger(
            subsystem: Bundle.main.bundleIdentifier!,
            category: String(describing: TreeViewModel.self)
        )

    override public init(store: StateStore, entryUsecase: any EntryUseCaseProtocol) {
        super.init(store: store, entryUsecase: entryUsecase)
    }

    /// Reset and refresh entire tree (loses expanded state, only for full refresh)
    func resetGroupTree() async {
        Self.logger.info("[resetGroupTree] load and reset group root (full refresh)")
        do {
            let root = try await entryUsecase.getTreeRoot()
            store.resetTree(root: root)
            expandedNodes.removeAll()
        } catch {
            sentAlert("load group tree failed: \(error)")
        }
    }

    /// Smart refresh - preserves expanded state
    /// Call this when tree structure changes locally (e.g., add/delete single node)
    func refreshGroupTree() async {
        Self.logger.info("[refreshGroupTree] smart refresh, preserving expanded state")
        do {
            let root = try await entryUsecase.getTreeRoot()

            // Collect expanded node URIs before refresh
            collectExpandedUris(from: store.treeChildren, into: &expandedNodes)

            // Perform full refresh
            store.resetTree(root: root)

            // Restore expanded state: only keep expanded state for nodes that still exist
            expandedNodes = expandedNodes.filter { store.getTreeGroup(uri: $0) != nil }
        } catch {
            sentAlert("refresh group tree failed: \(error)")
        }
    }

    /// Recursively collect expanded node URIs
    private func collectExpandedUris(from nodes: [TreeNode], into set: inout Set<String>) {
        for node in nodes {
            if expandedNodes.contains(node.uri) {
                set.insert(node.uri)
            }
            if let children = node.children {
                collectExpandedUris(from: children, into: &set)
            }
        }
    }

    /// Mark node as expanded
    func setNodeExpanded(_ uri: String) {
        expandedNodes.insert(uri)
    }

    /// Mark node as collapsed
    func setNodeCollapsed(_ uri: String) {
        expandedNodes.remove(uri)
    }

}
