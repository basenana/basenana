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

    var body: some View {
        List(selection: store.binding(for: \.sidebarSelection, toAction: {
            .updateSidebarSelection(select: $0)
        })){
            NavigationLink(value: Destination.groupList(group: store.state.fsInfo.inboxGroupModel())){
                SidebarIconView(imageName: "tray.full.fill", title: "Inbox", color: .blue)
            }
            
            NavigationLink(value: Destination.readDocuments(prespective: .unread)){
                SidebarIconView(imageName: "circle.fill", title: "Unread", color: .brown)
            }
            
            NavigationLink(value: Destination.readDocuments(prespective: .marked)){
                SidebarIconView(imageName: "bookmark.fill", title: "Marked", color: .yellow)
            }

            Section("GROUPS"){
                SidebarGroupsView()
            }
        }
        .listStyle(.sidebar)
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
