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
    private var parentID: Int64
    private var targetID: Int64 = -1 // default no select
    private var viewModel: TreeViewModel
    
    @State private var targetEntry: EntryDetail? = nil

    public init(parentID: Int64, viewModel: TreeViewModel) {
        self.parentID = parentID
        self.viewModel = viewModel
    }
    
    public init(parentID: Int64, targetEntry: Int64, viewModel: TreeViewModel) {
        self.parentID = parentID
        self.targetID = targetEntry
        self.viewModel = viewModel
    }
    
    public var body: some View {
        VStack {
            if targetEntry?.isGroup ?? false {
                Section{
                    Button("Open", action: {
                        // goto group view
                    })
                }
            }
            
            Section{
                Menu("New") {
                    Button("Group", action: {
                        // show create group form
                    })
                    Button("RSS Feed", action: {
                        // show create rss form
                    })
                    Button("Dynamic Group", action: {})
                }
            }
            
            if !(targetEntry?.isGroup ?? true){
                WebFileMenuView(viewModel: viewModel, targetEntry: targetEntry!)
            }

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
            
            if !(targetEntry?.isGroup ?? true){
                Section{
                    Menu("Mark") {
                        Button("As Marked", action: { print("Option 1 selected") })
                        Button("As Unread", action: { print("Option 2 selected") })
                    }
                }
            }
        }
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

let entries = try! MockEntryTreeUseCase().listChildren(entry: 1)

#Preview {
    if #available(macOS 14.0, *) {
        List{
            MenuView(parentID: 1010, viewModel: TreeViewModel(store: StateStore.empty, treeUsecase: MockEntryTreeUseCase(), entryUsecase: MockEntryUseCase()))
        }
    }
}

#endif
