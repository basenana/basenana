//
//  EntryMenuView.swift
//  Entry
//
//  Created by Hypo on 2024/9/22.
//

import Foundation
import SwiftUI
import Entities
import AppState
import Styleguide


public struct EntryMenuView: View {
    @State private var groupTree = GroupTree.shared
    @State private var viewModel: GroupTableViewModel
    
    public init(viewModel: GroupTableViewModel) {
        self.viewModel = viewModel
    }
    
    public var body: some View {
        VStack {
            if canBeOpen() {
                Section{
                    Button("Open", action: { viewModel.store.dispatch(.gotoDestination(.groupList(group: targets.first!.id))) })
                }
            }
            
            if canCreateGroup(){
                Section{
                    Menu("New") {
                        Button("Group", action: {
                            // show create group form
                            viewModel.createGroupType = .standard
                            viewModel.showCreateGroup.toggle()
                        })
                        Button("RSS Feed", action: {
                            // show create rss form
                            viewModel.createGroupType = .feed
                            viewModel.showCreateGroup.toggle()
                        })
                        Button("Dynamic Group", action: {
                            viewModel.createGroupType = .dynamic
                            viewModel.showCreateGroup.toggle()
                        })
                    }
                }
            }
            
            if canBeEdit() {
                Section{
                    if onlyOneSelected() {
                        Button("Rename", action: { viewModel.showRenameEntry.toggle() })
                    }
                    Button("Delete", action: { viewModel.showDeleteConfirm.toggle() })
                }
                
                Section{
                    Menu("Move To") {
                        ForEach(groupTree.children ?? []){ childGroup in
                            GroupDestinationView(
                                group: childGroup,
                                childKeyPath: \.children,
                                action: { moveEntriesToGroup(newParent: $0.id ) }
                            )
                        }
                    }
                    Menu("Replicate To") {
                        ForEach(groupTree.children ?? []){ childGroup in
                            GroupDestinationView(
                                group: childGroup,
                                childKeyPath: \.children,
                                action: { replicateEntryToGroup(newParent: $0.id) }
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
            return target.isGroup && target.id != groupTree.root.id
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
            if  target.id == groupTree.root.id || isInternalFile(target){
                return false
            }
        }
        return true
    }
    
    func moveEntriesToGroup(newParent: Int64) {
        Task {
            let _ = await viewModel.moveEntriesToGroup(entries: targets.map({$0.id}), newParent: newParent)
        }
    }
    
    func replicateEntryToGroup(newParent: Int64) {
        Task {
            await viewModel.replicateEntryToGroup(entries: targets.map({$0.id}), newParent: newParent)
        }
    }
}


struct GroupDestinationView: View {
    let group: GroupLeaf
    let childKeyPath: KeyPath<GroupLeaf, [GroupLeaf]?>
    let action: (_: GroupLeaf) async -> Void
    
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


#if DEBUG

import DomainTestHelpers
struct EntryMenuPreview: View {
    
    var body: some View {
        List {
            EntryMenuView(viewModel: GroupTableViewModel(store: StateStore.empty, entryUsecase: MockEntryUseCase()))
        }
    }
}



#Preview {
    EntryMenuPreview()
}

#endif
