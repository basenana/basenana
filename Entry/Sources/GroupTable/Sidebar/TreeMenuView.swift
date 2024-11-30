//
//  TreeMenuView.swift
//  Entry
//
//  Created by Hypo on 2024/10/10.
//

import Foundation
import SwiftUI
import Entities
import AppState
import UseCaseProtocol


struct TreeMenuView: View {
    @State private var groupTree = GroupTree.shared
    @State private var target: Entities.Group
    @State private var targetDetail: EntryDetail?
    @State private var viewModel: TreeViewModel
    
    public init(target: Entities.Group, viewModel: TreeViewModel) {
        self.target = target
        self.viewModel = viewModel
    }
    
    public var body: some View {
        VStack {
            if canCreateGroup(){
                Section{
                    Menu("New") {
                        Button("Group", action: {
                            // show create group form
                            viewModel.createGroupType = .standard
                            viewModel.createGroupInParent = target
                            viewModel.showCreateGroup.toggle()
                        })
                        Button("RSS Feed", action: {
                            // show create rss form
                            viewModel.createGroupType = .feed
                            viewModel.createGroupInParent = target
                            viewModel.showCreateGroup.toggle()
                        })
                        Button("Dynamic Group", action: {
                            viewModel.createGroupType = .dynamic
                            viewModel.createGroupInParent = target
                            viewModel.showCreateGroup.toggle()
                        })
                    }
                }
            }
            
            if canBeEdit() {
                Section{
                    Button("Rename", action: {
                        viewModel.renameEntry = target.id
                        viewModel.showRenameEntry.toggle()
                    })
                    Button("Delete", action: {})
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
                }
            }
            
        }
    }
    
    func canCreateGroup() -> Bool {
        return !isInternalFile(target)
    }
    
    func canBeEdit() -> Bool {
        return target.id != groupTree.root.id && !isInternalFile(target)
    }
    
    func moveEntriesToGroup(newParent: Int64) {
        Task {
            let _ = await viewModel.moveEntriesToGroup(entries: [target.id], newParent: newParent)
        }
    }
}
