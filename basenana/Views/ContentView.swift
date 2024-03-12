//
//  ContentView.swift
//  basenana
//
//  Created by Hypo on 2024/2/27.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @State private var isShowingQuickInbox = false

    var body: some View {
        NavigationSplitView {
            SidebarView()
            .frame(minWidth: 180,idealWidth: 180)
            .toolbar {
                ToolbarItem {
                    Button(action: quickInbox) {
                        Label("Quick Inbox", systemImage: "plus")
                    }
                }
            }
            .sheet(isPresented: $isShowingQuickInbox, content: {
                QuickInboxView(isShowingQuickInbox: $isShowingQuickInbox)
            })
        } detail: {
            Text("Select an item")
        }
    }

    private func quickInbox() {
        withAnimation {
            isShowingQuickInbox.toggle()
        }
    }
}

