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

    var body: some View {
        List{
            NavigationLink {
                GroupView(groupID: inboxEntryID).id(inboxEntryID)
                    .navigationTitle("Inbox")
            } label: {
                HStack{
                    Image(systemName: "tray.fill").foregroundColor(.blue)
                    Text("Inbox")
                }.frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.vertical, 5)
            }
            
            NavigationLink {
                DocumentView()
                    .navigationTitle("Unread")
            } label: {
                HStack{
                    Image(systemName: "circle.fill").foregroundColor(.brown)
                    Text("Unread")
                }.frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.vertical, 5)
            }
            
            NavigationLink {
            } label: {
                HStack{
                    Image(systemName: "bookmark.fill").foregroundColor(.yellow)
                    Text("Marked")
                }.frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.vertical, 5)
            }
            Section("GROUPS"){
                SidebarGroupsView()
            }
            .onAppear{
                groupService.initGroupTree()
            }
        }
        .listStyle(.sidebar)
        .overlay(alignment: .bottom, content: {SidebarButtonView()})
    }
}

#Preview {
    return SidebarView()
}
