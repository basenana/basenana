//
//  SettingsView.swift
//  basenana
//
//  Created by Hypo on 2024/4/19.
//

import SwiftUI
import AppState


struct SettingsView: View {
    @State private var state = StateStore.shared
    @State private var visibility: NavigationSplitViewVisibility = .doubleColumn
    @State var currentCategory: SettingCategory = .general
    var body: some View {
        NavigationSplitView(columnVisibility: $visibility) {
            List(selection: $currentCategory) {
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
            .toolbar(removing: .sidebarToggle)
        } detail: {
            VStack {
                switch currentCategory {
                case .general:
                    GeneralSettingView()
                case .appearance:
                    AppearanceSettingView()
                case .reading:
                    ReadingSettingView()
                case .document:
                    DocumentSettingView()
                case .database:
                    DatabaseSettingView()
                }
            }
            .padding(.vertical, 10)
            .frame(minWidth: 400)
            .navigationTitle("Setting")
        }
        .preferredColorScheme(state.setting.appearance.overColorScheme)
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


