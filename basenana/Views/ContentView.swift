//
//  ContentView.swift
//  basenana
//
//  Created by Hypo on 2024/2/27.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var items: [Item]
    @State private var isShowingQuickInbox = false

    var body: some View {
        NavigationSplitView {
        SidebarView(groups: buildGroups())
            .frame(minWidth: 180,idealWidth: 180)
            .toolbar {
                ToolbarItem {
                    Button(action: quickInbox) {
                        Label("Add Item", systemImage: "plus")
                    }
                }
            }
            // Show URL Form as a sheet
            .sheet(isPresented: $isShowingQuickInbox, content: {
                QuickInboxView()
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
        .modelContainer(for: Item.self, inMemory: true)
}
