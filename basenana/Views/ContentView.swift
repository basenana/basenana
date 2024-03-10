//
//  ContentView.swift
//  basenana
//
//  Created by Hypo on 2024/2/27.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @EnvironmentObject var entryService: EntryService
    @State private var rootGroups: [GroupTreeViewModel] = []
    @State private var isShowingQuickInbox = false

    var body: some View {
        NavigationSplitView {
            SidebarView(groups: $rootGroups)
            .frame(minWidth: 180,idealWidth: 180)
            .onAppear{
                rootGroups = entryService.listRootGroupTree()
            }
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

#Preview {
    ContentView()
        .environmentObject(EntryService())
}
