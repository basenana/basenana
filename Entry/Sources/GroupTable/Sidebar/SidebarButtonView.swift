//
//  SidebarButtonView.swift
//  basenana
//
//  Created by Hypo on 2024/4/13.
//

import SwiftUI
import Styleguide

struct SidebarButtonView: View {
    @State private var viewModel: TreeViewModel
    @State private var groupTree = GroupTree.shared
    
    init(viewModel: TreeViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        HStack(content: {
            Button(action: {
                viewModel.showQuickInbox.toggle()
            }, label: {
                Image(systemName: "tray.and.arrow.down")
            })
            .buttonStyle(.accessoryBar)
            
            Button(action: {
                viewModel.createGroupType = .standard
                viewModel.createGroupInParent = groupTree.root
                viewModel.showCreateGroup.toggle()
            }, label: {
                Image(systemName: "folder.badge.plus")
            })
            .buttonStyle(.accessoryBar)
            
            Spacer()
            
            Button(action: {
                //                store.dispatch(.setDestination(to: [.workflowDashboard]))
            }, label: {
                Image(systemName: "ellipsis.curlybraces")
            })
            .buttonStyle(.accessoryBar)
        })
        .sheet(isPresented: $viewModel.showQuickInbox){
            QuickInboxView(viewModel: viewModel)
        }
        .sheet(isPresented: $viewModel.showCreateGroup){
            GroupCreateView(
                parent: viewModel.createGroupInParent,
                groupType: .standard,
                viewModel: CreateDeleteViewModel(store: viewModel.store, entryUsecase: viewModel.entryUsecase),
                showCreateGroup: $viewModel.showCreateGroup)
        }
        .padding(5)
        .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/,alignment: .leading)
    }
}

