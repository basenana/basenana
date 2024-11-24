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
    @State private var target: Entities.Group
    @State private var targetDetail: EntryDetail?
    @State private var viewModel: TreeViewModel
    
    public init(target: Entities.Group, viewModel: TreeViewModel) {
        self.target = target
        self.viewModel = viewModel
    }
    
    public init(viewModel: TreeViewModel) {
        self.target = viewModel.root
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
            
        }
    }
    
    func canCreateGroup() -> Bool {
        return target.id != viewModel.inbox.id
    }
    
    func canBeEdit() -> Bool {
        return target.id != viewModel.root.id && target.id != viewModel.inbox.id
    }
}
