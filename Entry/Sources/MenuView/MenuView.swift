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
    @State private var viewModel: MenuViewModel
    
    public init(viewModel: MenuViewModel) {
        self.viewModel = viewModel
    }
    
    public var body: some View {
        VStack {
            if let group = viewModel.group {
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
            
            // web page
            Section{
                Button("Launch URL", action: {
                    for pk in [Property.WebPageURL, Property.WebSiteURL]{
                        if let proVal = viewModel.getProperty(k: pk){
                            if let pageUrl = URL(string: proVal){
                                //                                openURL.callAsFunction(pageUrl){ result in
                                //                                    log.info("open docuemnt url \(proVal), resule: \(result)")
                                //                                }
                                break
                            }
                        }
                    }
                })
                Button("Copy URL", action: {
                    for pk in [Property.WebPageURL, Property.WebSiteURL]{
                        if let proVal = viewModel.getProperty(k: pk){
                            //                            copyToClipBoard(textToCopy: pro.value)
                            break
                        }
                    }
                })
            }
            
            Section{
                Button("Rename", action: {})
                Button("Delete", action: {})
            }
            
            Section{
                Menu("Move To") {
                    ForEach(viewModel.store.groupTree.children ?? []){ childGroup in
                        GroupDestinationView(
                            group: childGroup,
                            childKeyPath: \.children,
                            action: { _ in }
                        )
                    }
                }
                Menu("Replicate To") {
                    ForEach(viewModel.store.groupTree.children ?? []){ childGroup in
                        GroupDestinationView(
                            group: childGroup,
                            childKeyPath: \.children,
                            action: { _ in }
                        )
                    }
                }
            }
            
            if viewModel.group == nil {
                Section{
                    Menu("Mark") {
                        Button("As Marked", action: { print("Option 1 selected") })
                        Button("As Unread", action: { print("Option 2 selected") })
                    }
                }
            }
        }
        .task {
            do {
                try await viewModel.initEntryCache()
            } catch {
                print("fetch entry property failed \(error)")
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
            MenuView(viewModel: MenuViewModel(store: StateStore.empty, entry: entries[0]))
        }
    }
}

#endif
