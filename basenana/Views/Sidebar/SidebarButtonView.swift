//
//  SidebarButtonView.swift
//  basenana
//
//  Created by Hypo on 2024/4/13.
//

import SwiftUI

struct SidebarButtonView: View {
    
    @Environment(\.colorScheme) var colorScheme
    @State private var showQuickInbox = false
    @State private var showCreateGroup = false
    @Binding var selection: Set<GroupViewModel.ID>
    
    var body: some View {
        HStack(content: {
            Button(action: {
                showQuickInbox = true
            }, label: {
                Image(systemName: "tray.and.arrow.down")
            })
            .buttonStyle(.accessoryBar)
            .sheet(isPresented: $showQuickInbox) {
                QuickInboxView(showQuickInbox: $showQuickInbox)
            }
            
            Button(action: {
                showCreateGroup = true
            }, label: {
                Image(systemName: "folder.badge.plus")
            })
            .buttonStyle(.accessoryBar)
            .sheet(isPresented: $showCreateGroup){
                let p = entryService.getEntry(entryID: selection.first)
                GroupCreateView(showCreateGroup: $showCreateGroup, parent: p)
            }
            
            Spacer()
        })
        .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/,alignment: .leading)
        .padding(5)
        .background(Color.background)
    }
    
}

