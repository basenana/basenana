//
//  SidebarView.swift
//  basenana
//
//  Created by Hypo on 2024/2/29.
//

import os
import Foundation
import SwiftUI
import AppState
import Styleguide


public struct SidebarView: View {
    
    @State private var viewModel: TreeViewModel
    @State private var selection: Destination? = nil
    
    private static let logger = Logger(
            subsystem: Bundle.main.bundleIdentifier!,
            category: String(describing: SidebarView.self)
        )
    
    public init(viewModel: TreeViewModel) {
        self.viewModel = viewModel
    }
    
    public var body: some View {
        List(selection: $selection){
            NavigationLink(value: Destination.groupList(group: viewModel.store.fsInfo.inboxID)){
                SidebarIconView(imageName: "tray.full.fill", title: "Inbox", color: .InboxColor)
            }.id("nav_inbox")
            
            NavigationLink(value: Destination.listDocuments(prespective: .unread)){
                SidebarIconView(imageName: "circle.inset.filled", title: "Unread", color: .UnreadColor)
            }.id("nav_unread")
            
            NavigationLink(value: Destination.listDocuments(prespective: .marked)){
                SidebarIconView(imageName: "bookmark.fill", title: "Marked", color: .MarkedColor)
            }.id("nav_marked")
            
            
            Section("GROUPS"){
                TreeListView(viewModel: viewModel)
            }
        }
        .onChange(of: selection){
            if let s = selection{
                resetDestination(s)
                if case.groupList(let grp) = s {
                    viewModel.selectedGroupId = grp
                    Self.logger.notice("[SidebarView] selected group \(grp)")
                }else {
                    viewModel.selectedGroupId = nil
                }
            }
        }
        .task {
            await viewModel.resetGroupTree()
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

