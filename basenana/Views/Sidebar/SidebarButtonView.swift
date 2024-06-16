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
    @Binding var refreshToggle: Bool
    
    var body: some View {
        HStack(content: {
            Button(action: {
                showQuickInbox = true
            }, label: {
                Image(systemName: "tray.and.arrow.down")
            })
            .buttonStyle(.accessoryBar)
            .sheet(isPresented: $showQuickInbox) {
                QuickInboxView(showQuickInbox: $showQuickInbox, refreshToggle: $refreshToggle)
            }
            
            Button(action: {
                showCreateGroup = true
            }, label: {
                Image(systemName: "folder.badge.plus")
            })
            .buttonStyle(.accessoryBar)
            .sheet(isPresented: $showCreateGroup){
                GroupCreateView(parentID: selection.first, showCreateGroup: $showCreateGroup)
            }
            
            Spacer()
        })
        .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/,alignment: .leading)
        .padding(5)
        .background(Color.background)
    }
    
}

