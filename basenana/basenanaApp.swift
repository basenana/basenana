//
//  basenanaApp.swift
//  basenana
//
//  Created by Hypo on 2024/2/27.
//

import SwiftUI
import SwiftData

@main
struct basenanaApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            EntryModel.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        
        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
    
    var body: some Scene {
        WindowGroup {
            NavigationView {
                SidebarView()
                .frame(minWidth: 180,idealWidth: 180)
            }
            .toolbar {
                ToolbarItemGroup(placement: .navigation) {
                    Button(action: {
                        NSApp.keyWindow?.initialFirstResponder?.tryToPerform(
                            #selector(NSSplitViewController.toggleSidebar(_:)), with: nil)
                    }, label: {
                        Image(systemName: "sidebar.left")
                    })
                }
            }
        }
        .modelContainer(sharedModelContainer)
        .environmentObject(EntryService(modelContext: sharedModelContainer.mainContext))
        .environmentObject(GroupService(modelContext: sharedModelContainer.mainContext))
    }
}
