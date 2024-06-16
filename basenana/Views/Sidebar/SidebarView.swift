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
    @State var selection = Set<GroupViewModel.ID>()
    @State private var refreshToggle = false
    @Environment(AlertStore.self) var alert

    var body: some View {
        List(selection: $selection){
            NavigationLink {
                GroupView(groupID: inboxEntryID, refreshToggle: $refreshToggle).id(inboxEntryID)
                    .navigationTitle("Inbox")
            } label: {
                HStack{
                    Image(systemName: "tray.full.fill").foregroundColor(.blue)
                    Text("Inbox")
                }.frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.vertical, 5)
            }
            
            NavigationLink {
                DocumentView(filter: Docfilter(unread: true)).id("unread")
                    .toolbar(removing: .sidebarToggle)
                    .navigationTitle("Unread")
            } label: {
                HStack{
                    Image(systemName: "circle.fill").foregroundColor(.brown)
                    Text("Unread")
                }.frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.vertical, 5)
            }
            
            NavigationLink {
                DocumentView(filter: Docfilter(marked: true)).id("marked")
                    .toolbar(removing: .sidebarToggle)
                    .navigationTitle("Marked")
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
                initGroupTree()
            }
            .onChange(of: GroupRoot.updateAt) {
                initGroupTree()
            }
        }
        .listStyle(.sidebar)
        .overlay(alignment: .bottom, content: {SidebarButtonView(selection: $selection, refreshToggle: $refreshToggle)})
    }
    
    func initGroupTree(){
        Task.detached{
            do {
                try service.initGroupTree()
            } catch {
                await alert.trigger(message: "\(error)")
            }
        }
    }
}

#Preview {
    return SidebarView()
}
