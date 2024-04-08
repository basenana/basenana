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
            DocumentModel.self,
            DialogueModel.self,
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
            MainView()
                .frame(minWidth: 1000, minHeight: 600)
        }
        .modelContainer(sharedModelContainer)
        .environmentObject(EntryService(modelContext: sharedModelContainer.mainContext))
        .environmentObject(GroupService(modelContext: sharedModelContainer.mainContext))
        .environmentObject(DocumentService(modelContext: sharedModelContainer.mainContext))
        .environmentObject(DialogueService(modelContext: sharedModelContainer.mainContext))
    }
}
