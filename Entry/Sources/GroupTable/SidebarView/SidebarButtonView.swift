//
//  SidebarButtonView.swift
//  basenana
//
//  Created by Hypo on 2024/4/13.
//

import SwiftUI
import Styleguide

@available(macOS 14.0, *)
struct SidebarButtonView: View {
    @State private var viewModel: TreeViewModel
    
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
            InboxView(viewModel: viewModel)
        }
        .sheet(isPresented: $viewModel.showCreateGroup){
            GroupCreateView(viewModel: viewModel)
        }
        .padding(5)
        .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/,alignment: .leading)
    }
}

