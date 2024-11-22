//
//  MenuView.swift
//  Entry
//
//  Created by Hypo on 2024/9/22.
//

import Foundation
import SwiftUI
import Entities
import AppState
import Styleguide


@available(macOS 14.0, *)
public struct MenuView: View {
    @State private var targetID: Int64
    @State private var target: EntryDetail? = nil
    @State private var viewModel: TreeViewModel
    
    public init(targetID: Int64, viewModel: TreeViewModel) {
        self.targetID = targetID
        self.viewModel = viewModel
    }
    
    public var body: some View {
        VStack {
#if DEBUG
            Text("target: \(target?.name ?? "unload: id-\(targetID)")")
#endif
            
            if canBeOpen() {
                Section{
                    Button("Open", action: { viewModel.store.dispatch(.gotoDestination(.groupList(group: target!.id))) })
                }
            }
            
            if canCreateGroup(){
                Section{
                    Menu("New") {
                        Button("Group", action: {
                            // show create group form
                            viewModel.createGroupType = .standard
                            viewModel.createGroupInParent = targetID
                            viewModel.showCreateGroup.toggle()
                        })
                        Button("RSS Feed", action: {
                            // show create rss form
                            viewModel.createGroupType = .feed
                            viewModel.createGroupInParent = targetID
                            viewModel.showCreateGroup.toggle()
                        })
                        Button("Dynamic Group", action: {
                            viewModel.createGroupType = .dynamic
                            viewModel.createGroupInParent = targetID
                            viewModel.showCreateGroup.toggle()
                        })
                    }
                }
            }
            
            if isFileTarget() {
                FileMenuView(viewModel: viewModel, target: target!)
            }
            
            if canBeEdit() {
                Section{
                    Button("Rename", action: {})
                    Button("Delete", action: {})
                }
                
                Section{
                    Menu("Move To") {
                        ForEach(viewModel.groupTree.children ?? []){ childGroup in
                            GroupDestinationView(
                                group: childGroup,
                                childKeyPath: \.children,
                                action: { _ in }
                            )
                        }
                    }
                    Menu("Replicate To") {
                        ForEach(viewModel.groupTree.children ?? []){ childGroup in
                            GroupDestinationView(
                                group: childGroup,
                                childKeyPath: \.children,
                                action: { _ in }
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
        .task {
            target = viewModel.describeEntry(entry: targetID)
        }
    }
    
    func isFileTarget() -> Bool {
        return target != nil && !target!.isGroup
    }
    
    func canBeOpen() -> Bool {
        return target != nil && target!.isGroup && target!.id != viewModel.root.id
    }
    
    func canCreateGroup() -> Bool {
        return target != nil && target!.id != viewModel.inbox.id
    }
    
    func canBeEdit() -> Bool {
        return target != nil && target!.id != viewModel.root.id && target!.id != viewModel.inbox.id
    }
}


@available(macOS 14.0, *)
struct GroupDestinationView: View {
    let group: GroupLeaf
    let childKeyPath: KeyPath<GroupLeaf, [GroupLeaf]?>
    let action: (_: GroupLeaf) ->Void
    
    var body: some View {
        if group[keyPath: childKeyPath] != nil {
            DisclosureGroup(
                isExpanded: /*@START_MENU_TOKEN@*/.constant(true)/*@END_MENU_TOKEN@*/,
                content: {
                    Menu(group.groupName) {
                        Button(group.groupName, action: { action(group) })
                        Divider()
                        ForEach(group[keyPath: childKeyPath] ?? []) { childGroup in
                            GroupDestinationView(group: childGroup, childKeyPath: childKeyPath, action: action)
                        }
                    }
                },
                label: {}
            ).disclosureGroupStyle(GroupDestDisclosureStyle())
        } else {
            Button(group.groupName, action: { action(group) })
        }
    }
}



#if DEBUG

import DomainTestHelpers

let entries = try! MockEntryUseCase().listChildren(entry: 1)

#Preview {
    if #available(macOS 14.0, *) {
        List{
            MenuView(targetID: 1010, viewModel: TreeViewModel(store: StateStore.empty, entryUsecase: MockEntryUseCase()))
        }
    }
}

#endif
