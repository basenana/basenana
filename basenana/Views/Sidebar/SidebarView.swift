//
//  SidebarView.swift
//  basenana
//
//  Created by Hypo on 2024/2/29.
//

import Foundation
import SwiftUI
import SwiftData

struct SidebarView: View {
    @Environment(Store.self) private var store: Store
    @State private var appConfiguration = AppConfiguration.share

    var body: some View {
        List(selection: store.binding(for: \.sidebarSelection, toAction: {
            .updateSidebarSelection(select: $0)
        })){
            NavigationLink(value: Destination.groupList(group: store.state.fsInfo.inboxGroupModel())){
                SidebarIconView(imageName: "tray.full.fill", title: "Inbox", color: .blue)
            }.id("nav_inbox")
            
            NavigationLink(value: Destination.readDocuments(prespective: .unread)){
                SidebarIconView(imageName: "circle.inset.filled", title: "Unread", color: .brown)
            }.id("nav_unread")
            
            NavigationLink(value: Destination.readDocuments(prespective: .marked)){
                SidebarIconView(imageName: "bookmark.fill", title: "Marked", color: .yellow)
            }.id("nav_marked")
            
            if appConfiguration.enableGlobalChart {
                NavigationLink(value: Destination.fridayChat){
                    SidebarIconView(imageName: "ellipsis.message.fill", title: "Hello Friday", color: .green)
                }.id("nav_hello_friday")
            }

            Section("GROUPS"){
                SidebarGroupsView()
            }
        }
        .listStyle(.sidebar)
        .padding(.bottom, 20)
        .overlay(alignment: .bottom, content: {SidebarButtonView()})
    }
}

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

#Preview {
    return SidebarView().environment(Store())
}
