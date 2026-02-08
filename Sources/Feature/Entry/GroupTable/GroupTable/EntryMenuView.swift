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
    @State private var viewModel: GroupTableViewModel

    public init(viewModel: GroupTableViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        VStack {
            if canBeOpen() {
                Section{
                    Button("Open", action: { gotoDestination(.groupList(groupUri: targets.first!.uri)) })
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
                        ForEach(store?.treeChildren ?? []){ childGroup in
                            GroupDestinationView(
                                group: childGroup,
                                childKeyPath: \.children,
                                action: { moveEntriesToGroup(newParentUri: $0.uri ) }
                            )
                        }
                    }
                    Menu("Replicate To") {
                        ForEach(store?.treeChildren ?? []){ childGroup in
                            GroupDestinationView(
                                group: childGroup,
                                childKeyPath: \.children,
                                action: { replicateEntryToGroup(newParentUri: $0.uri) }
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

    func isFileTarget() -> Bool {
        guard !onlyOneSelected() else {
            return false
        }

        if let target = targets.first {
            return !target.isGroup
        }
        return false
    }

    func canBeOpen() -> Bool {
        guard onlyOneSelected() else {
            return false
        }
        if let target = targets.first {
            return target.isGroup && target.id != store?.rootGroup?.id
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


struct GroupDestinationView: View {
    let group: TreeNode
    let childKeyPath: KeyPath<TreeNode, [TreeNode]?>
    let action: (_: TreeNode) async -> Void

    var body: some View {
        if group[keyPath: childKeyPath] != nil {
            DisclosureGroup(
                isExpanded: /*@START_MENU_TOKEN@*/.constant(true)/*@END_MENU_TOKEN@*/,
                content: {
                    Menu(group.groupName) {
                        Button("\(group.groupName) 👈🏻", action: { Task { await action(group) }})
                        Divider()
                        ForEach(group[keyPath: childKeyPath] ?? []) { childGroup in
                            GroupDestinationView(group: childGroup, childKeyPath: childKeyPath, action: action)
                        }
                    }
                },
                label: {}
            ).disclosureGroupStyle(GroupDestDisclosureStyle())
        } else {
            Button(group.groupName, action: { Task { await action(group) }})
        }
    }
}

