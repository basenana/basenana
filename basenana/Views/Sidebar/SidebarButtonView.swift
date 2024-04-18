//
//  SidebarButtonView.swift
//  basenana
//
//  Created by Hypo on 2024/4/13.
//

import SwiftUI

struct SidebarButtonView: View {
    @State private var isShowingQuickInbox = false

    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        HStack(content: {
            Button(action: {
                isShowingQuickInbox.toggle()
            }, label: {
                Image(systemName: "plus")
            })
            .buttonStyle(.accessoryBar)
            
            Spacer()
            Button(action: {
                syncService.resyncBackground()
            }, label: {
                Image(systemName: syncService.isSyncing ? "arrow.triangle.2.circlepath.icloud" : "checkmark.icloud")
            })
            .buttonStyle(.accessoryBar)
        })
        .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/,alignment: .leading)
        .padding(5)
        .background(Color.background)
        
        .sheet(isPresented: $isShowingQuickInbox) {
            QuickInboxView(isShowingQuickInbox: $isShowingQuickInbox)
        }
    }
    
}

