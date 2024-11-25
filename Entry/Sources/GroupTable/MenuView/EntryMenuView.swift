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


@available(macOS 14.0, *)
public struct EntryMenuView: View {
    @State private var target: EntryInfo
    @State private var targetDetail: EntryDetail?
    @State private var viewModel: TreeViewModel
    
    public init(target: EntryInfo, viewModel: TreeViewModel) {
        self.target = target
        self.viewModel = viewModel
    }
    
    public init(target: EntryDetail, viewModel: TreeViewModel) {
        self.target = target.toInfo()!
        self.targetDetail = target
        self.viewModel = viewModel
    }
    
    public var body: some View {
        VStack {
            
            if canBeOpen() {
                Section{
                    Button("Open", action: { viewModel.store.dispatch(.gotoDestination(.groupList(group: target.id))) })
                }
            }
            
            if canCreateGroup(){
                Section{
                    Menu("New") {
                        Button("Group", action: {
                            // show create group form
                            viewModel.createGroupType = .standard
                            viewModel.createGroupInParent = target.id
                            viewModel.showCreateGroup.toggle()
                        })
                        Button("RSS Feed", action: {
                            // show create rss form
                            viewModel.createGroupType = .feed
                            viewModel.createGroupInParent = target.id
                            viewModel.showCreateGroup.toggle()
                        })
                        Button("Dynamic Group", action: {
                            viewModel.createGroupType = .dynamic
                            viewModel.createGroupInParent = target.id
                            viewModel.showCreateGroup.toggle()
                        })
                    }
                }
            }
            
            if targetDetail != nil && isFileTarget() {
                FileMenuView(viewModel: viewModel, target: targetDetail!)
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
                                action: { let _ = await viewModel.moveEntriesToGroup(entryURLs: [EntryUrl(entryID: target.id)], newParent: $0.id ) }
                            )
                        }
                    }
                    Menu("Replicate To") {
                        ForEach(viewModel.groupTree.children ?? []){ childGroup in
                            GroupDestinationView(
                                group: childGroup,
                                childKeyPath: \.children,
                                action: { viewModel.replicateEntryToGroup(entry: target.id, newParent: $0.id) }
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
            targetDetail = await viewModel.describeEntry(entry: target.id)
        }
    }
    
    func isFileTarget() -> Bool {
        return !target.isGroup
    }
    
    func canBeOpen() -> Bool {
        return target.isGroup && target.id != viewModel.root.id
    }
    
    func canCreateGroup() -> Bool {
        return target.id != viewModel.inbox.id
    }
    
    func canBeEdit() -> Bool {
        return target.id != viewModel.root.id && target.id != viewModel.inbox.id
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


struct FileMenuView: View {
    private var viewModel: TreeViewModel
    private var target: EntryDetail?
    
    init(viewModel: TreeViewModel, target: EntryDetail?) {
        self.viewModel = viewModel
        self.target = target
    }
    
    var body: some View {
        // web file
        if let u = parseUrlString(urlStr: getEntryProperty(keys: [Property.WebPageURL, Property.WebSiteURL])?.value ?? "" ){
            Section(){
                Button("Launch URL", action: {
                    openUrlInBrowser(url: u)
                })
                Button("Copy URL", action: {
                    copyToClipBoard(content: "\(u)")
                })
            }
        }
    }
    
    func getEntryProperty(keys: [String]) -> EntryProperty?{
        guard target != nil else {
            return nil
        }
        for k in keys {
            for p in target!.properties {
                if p.key == k {
                    return p
                }
            }
        }
        return nil
    }
}


#if DEBUG

import DomainTestHelpers
struct EntryMenuPreview: View {
    @State private var entry: EntryInfo? = nil
    
    var body: some View {
        List {
            if let entry = entry {
                EntryMenuView(target: entry, viewModel: TreeViewModel(store: StateStore.empty, entryUsecase: MockEntryUseCase()))
            } else {
                Text("Loading...")
            }
        }
        .task {
            do {
                entry = try await MockEntryUseCase().getEntryDetails(entry: 1010).toInfo()
            } catch {
                print("Failed to load entry details: \(error)")
            }
        }
    }
}



#Preview {
    EntryMenuPreview()
}

#endif
