//
//  SidebarView.swift
//  basenana
//
//  Created by Hypo on 2024/2/29.
//

import Foundation
import SwiftUI
import AppState


@available(macOS 14.0, *)
public struct SidebarView: View {
    
    @State private var viewModel: TreeViewModel
    
    public init(viewModel: TreeViewModel) {
        self.viewModel = viewModel
    }
    
    public var body: some View {
        List(selection: viewModel.store.binding(for: \.sidebarSelection, toAction: { .updateSidebarSelection(select: $0) })){
            NavigationLink(value: Destination.groupList(group: viewModel.store.fsInfo.inboxID)){
                SidebarIconView(imageName: "tray.full.fill", title: "Inbox", color: .blue)
            }.id("nav_inbox")
            
            NavigationLink(value: Destination.listDocuments(prespective: .unread)){
                SidebarIconView(imageName: "circle.inset.filled", title: "Unread", color: .brown)
            }.id("nav_unread")
            
            NavigationLink(value: Destination.listDocuments(prespective: .marked)){
                SidebarIconView(imageName: "bookmark.fill", title: "Marked", color: .yellow)
            }.id("nav_marked")
            
            
            Section("GROUPS"){
                TreeListView(viewModel: viewModel)
            }
        }
        .task {
            await viewModel.resetGroupTree()
        }
        .contextMenu{
            TreeMenuView(viewModel: viewModel)
        }
        .listStyle(.sidebar)
        .padding(.bottom, 40)
        .overlay(alignment: .bottom, content: { SidebarButtonView(viewModel: viewModel) })
    }
}


@available(macOS 14.0, *)
struct SidebarIconView: View {
    var imageName: String
    var title: String
    var color: Color?
    
    var body: some View {
        HStack{
            Image(systemName: imageName).foregroundColor(color)
            Text(title)
        }.frame(maxWidth: .infinity, alignment: .leading)
            .padding(.vertical, 5)
    }
}

