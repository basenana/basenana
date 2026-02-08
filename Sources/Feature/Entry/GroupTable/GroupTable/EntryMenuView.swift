//
//  EntryMenuView.swift
//  Entry
//
//  Created by Hypo on 2024/9/22.
//

import Foundation
import SwiftUI
import Domain
import Domain
import Styleguide


public struct EntryMenuView: View {
    @Environment(\.stateStore) private var store
    @Environment(\.openWindow) private var openWindow
    @State private var viewModel: GroupTableViewModel

    public init(viewModel: GroupTableViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        VStack {
            if canOpenAsGroup() {
                Section{
                    Button("Open") {
                        gotoDestination(.groupList(groupUri: targets.first!.uri))
                    }
                }
            } else if canOpenAsDocument() {
                Section{
                    Button("Open") {
                        openWindow(value: targets.first!.uri)
                    }
                }
            }

            if canCreateGroup(){
                Section{
                    Button("New Group") {
                        NotificationCenter.default.post(name: .createGroup, object: NewGroupRequest(parentUri: viewModel.group?.uri ?? "", groupType: .standard))
                    }
                }
            }

            if canBeEdit() {
                Section{
                    if onlyOneSelected() {
                        Button("Rename", action: {
                            NotificationCenter.default.post(name: .renameEntry, object: viewModel.selectedEntries.first?.uri ?? "")
                        })
                    }
                    Button("Delete", action: {
                        NotificationCenter.default.post(name: .deleteEntry, object: viewModel.selectedEntries.map({$0.uri}))
                    })
                }

                Section{
                    Menu("Move To") {
                        GroupDestinationList(
                            childKeyPath: \.children,
                            isGroup: allSelectedAreGroups(),
                            action: { await moveEntriesToGroup(newParentUri: $0) }
                        )
                    }

                    if canReplicate() {
                        Menu("Replicate To") {
                            GroupDestinationList(
                                childKeyPath: \.children,
                                isGroup: false,
                                action: { await replicateEntryToGroup(newParentUri: $0) }
                            )
                        }
                    }
                }
            }

            if isFileTarget() {
                Section{
                    Menu("Mark") {
                        Button("As Marked", action: { print("Option 1 selected") })
                        Button("As Unread", action: { print("Option 2 selected") })
                    }
                }
            }
        }
    }

    var targets: [EntryInfo] {
        get {
            viewModel.selectedEntries
        }
    }

    func hasSelected() -> Bool {
        return targets.count > 0
    }

    func onlyOneSelected() -> Bool {
        return targets.count == 1
    }

    func allSelectedAreGroups() -> Bool {
        return targets.allSatisfy { $0.isGroup }
    }

    func isFileTarget() -> Bool {
        guard !onlyOneSelected() else {
            return false
        }
        return targets.allSatisfy { !$0.isGroup }
    }

    func canReplicate() -> Bool {
        return targets.allSatisfy { !$0.isGroup }
    }

    func canOpenAsGroup() -> Bool {
        guard onlyOneSelected() else {
            return false
        }
        if let target = targets.first {
            return target.isGroup && target.id != store?.rootGroup?.id
        }
        return false
    }

    func canOpenAsDocument() -> Bool {
        guard onlyOneSelected() else {
            return false
        }
        if let target = targets.first {
            return !target.isGroup
        }
        return false
    }

    func canCreateGroup() -> Bool {
        if let grp = viewModel.group {
            return !isInternalFile(grp.toInfo()!)
        }
        return false
    }

    func canBeEdit() -> Bool {
        guard !targets.isEmpty else {
            return false
        }
        for target in targets {
            if  target.id == store?.rootGroup?.id || isInternalFile(target){
                return false
            }
        }
        return true
    }

    func moveEntriesToGroup(newParentUri: String) {
        Task {
            let _ = await viewModel.moveChildrenToGroup(entryUris: targets.map({$0.uri}), newParentUri: newParentUri)
        }
    }

    func replicateEntryToGroup(newParentUri: String) {
        Task {
            await viewModel.replicateEntryToGroup(entryUris: targets.map({$0.uri}), newParentUri: newParentUri)
        }
    }
}


/// Root directory selection list, automatically fetches treeChildren from store and displays Root option
struct GroupDestinationList: View {
    @Environment(\.stateStore) private var store

    let childKeyPath: KeyPath<TreeNode, [TreeNode]?>
    let isGroup: Bool
    let action: (String) async -> Void

    var body: some View {
        if isGroup && store?.rootGroup != nil {
            Button("📁 Root") {
                Task { await action("/") }
            }
            Divider()
        }
        ForEach(store?.treeChildren ?? []) { childGroup in
            GroupDestinationView(
                group: childGroup,
                childKeyPath: childKeyPath,
                isGroup: isGroup,
                action: action
            )
        }
    }
}

/// Single directory target view, recursively displays child directories
struct GroupDestinationView: View {
    let group: TreeNode
    let childKeyPath: KeyPath<TreeNode, [TreeNode]?>
    let isGroup: Bool
    let action: (String) async -> Void

    var body: some View {
        if group[keyPath: childKeyPath] != nil {
            DisclosureGroup(
                isExpanded: .constant(true),
                content: {
                    Menu(group.groupName) {
                        Button("📁 \(group.groupName)", action: { Task { await action(group.uri) }})
                        Divider()
                        ForEach(group[keyPath: childKeyPath] ?? []) { childGroup in
                            GroupDestinationView(
                                group: childGroup,
                                childKeyPath: childKeyPath,
                                isGroup: isGroup,
                                action: action
                            )
                        }
                    }
                },
                label: {}
            ).disclosureGroupStyle(GroupDestDisclosureStyle())
        } else {
            Button(group.groupName, action: { Task { await action(group.uri) }})
        }
    }
}

