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
                if let unwrappedID = selection.first {
                    showCreateGroup = true
                }
            }, label: {
                Image(systemName: "folder.badge.plus")
            })
            .buttonStyle(.accessoryBar)
            .sheet(isPresented: $showCreateGroup){
                if let unwrappedID = selection.first {
                    let entryId: Int64 = unwrappedID
                    let parent = entryService.getEntry(entryID: entryId)
                    if let p = parent {
                        GroupCreateView(showCreateGroup: $showCreateGroup, parent: p)
                    }
                }
            }
            
            Spacer()
        })
        .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/,alignment: .leading)
        .padding(5)
        .background(Color.background)
    }
    
}

