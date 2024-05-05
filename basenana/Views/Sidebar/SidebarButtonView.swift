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
            }, label: {
                Image(systemName: "folder.badge.plus")
            })
            .buttonStyle(.accessoryBar)
            
            Spacer()
            Button(action: {
                syncService.resyncBackground()
            }, label: {
                Image(systemName: syncStatus.isSyncing ? "arrow.triangle.2.circlepath.icloud" : "checkmark.icloud")
            })
            .buttonStyle(.accessoryBar)
        })
        .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/,alignment: .leading)
        .padding(5)
        .background(Color.background)
    }
    
}

