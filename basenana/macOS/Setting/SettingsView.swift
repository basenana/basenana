//
//  SettingsView.swift
//  basenana
//
//  Created by Hypo on 2024/4/19.
//

import SwiftUI
import AppState


struct SettingsView: View {
    @State private var visibility: NavigationSplitViewVisibility = .doubleColumn
    var body: some View {
        NavigationSplitView(columnVisibility: $visibility) {
            SettingSideBarView()
                .toolbar(removing: .sidebarToggle)
                .navigationDestination(for: SettingCategory.self) { category in
                    Group {
                        switch category {
                        case .general:
                            SettingDetailView()
                        case .appearance:
                            AppearanceSettingView()
                        case .reading:
                            SettingDetailView()
                        case .document:
                            SettingDetailView()
                        case .database:
                            DatabaseSettingView()
                        }
                    }
                    .frame(minWidth: 400)
                }
        } detail: {
            SettingDetailView()
                .frame(minWidth: 400)
                .navigationTitle("Setting")
        }
        .toolbarBackground(.hidden)
        .frame(width: 600, height: 450)
        .task {
            for await _ in Timer.publish(every: 0.3, on: .main, in: .common).autoconnect().values {
                if visibility != .doubleColumn {
                    visibility = .doubleColumn
                }
            }
        }
    }
}

struct SettingSideBarView: View {
    @State var currentCategory: SettingCategory = .appearance
       var body: some View {
           List {
               NavigationLink(value: SettingCategory.general) {
                   SettingSideBaLabelView(category: .general, image: "switch.2")
               }
               
               NavigationLink(value: SettingCategory.appearance) {
                   SettingSideBaLabelView(category: .appearance, image: "paintbrush")
               }

               NavigationLink(value: SettingCategory.reading) {
                   SettingSideBaLabelView(category: .reading, image: "eyeglasses")
               }

               NavigationLink(value: SettingCategory.document) {
                   SettingSideBaLabelView(category: .document, image: "doc.richtext")
               }
               
               NavigationLink(value: SettingCategory.database) {
                   SettingSideBaLabelView(category: .database, image: "tray.2")
               }
           }
           .navigationTitle("Setting_Title")
       }
}

struct SettingSideBaLabelView: View {
    @State private var category: SettingCategory
    @State private var image: String
    
    init(category: SettingCategory, image: String) {
        self.category = category
        self.image = image
    }
    var body: some View {
        Label(category.display, systemImage: image)
            .padding(.vertical, 10)
    }
}


struct SettingDetailView: View {
    var body: some View {
        Text("Setting")
    }
}


