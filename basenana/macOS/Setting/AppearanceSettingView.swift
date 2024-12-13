//
//  AppearanceSettingView.swift
//  basenana
//
//  Created by Hypo on 2024/12/8.
//

import Foundation
import SwiftUI
import AppState


struct AppearanceSettingView: View {
    
    @State var colorScheme: ColorSchemeSetting = .system
    @State var bookMark: Bool = true
    
    @State private var state = StateStore.shared
    @State private var appFontSize: Double = 1
    
    var body: some View {
        Form {
            Picker("Color Scheme", selection: $state.setting.appearance.appearance) {
                Text("System").tag("auto")
                Text("Light").tag("light")
                Text("Dark").tag("dark")
            }
            .pickerStyle(.segmented)
            
            Section("Application"){
                Picker("Language", selection: $state.setting.appearance.language) {
                    Text("English").tag("english")
                }
                .pickerStyle(.menu)
                Picker("Font", selection: $state.setting.appearance.appFont) {
                    Text("Default").tag("default")
                }
                .pickerStyle(.menu)
                
                LabeledContent {
                    Slider(
                        value: $appFontSize,
                        in: 1...5,
                        step: 1,
                        onEditingChanged: { editing in
                            state.setting.appearance.appFontSize = Int(appFontSize)
                        }
                    )
                    .labelsHidden()
                } label: {
                    Text("Font Size")
                    Text("x\(Int(appFontSize))")
                }
            }
            
            Section("Document List"){
                
                Picker("Unread List Model", selection: $state.setting.appearance.unreadReadModel) {
                    Text("Masonry").tag("masonry")
                    Text("Navigation").tag("navigation")
                }
                .pickerStyle(.segmented)
                Picker("Marked List Model", selection: $state.setting.appearance.markedReadModel) {
                    Text("Masonry").tag("masonry")
                    Text("Navigation").tag("navigation")
                }
                .pickerStyle(.segmented)
                
                Picker("Image Preview", selection: $state.setting.appearance.imagePreview) {
                    Text("None").tag("none")
                    Text("Large").tag("large")
                }
                .pickerStyle(.segmented)
                
                Toggle("Text Preview", isOn: $state.setting.appearance.contentPreview)
                    .toggleStyle(.switch)
            }
        }
        .onAppear{
            appFontSize = Double(state.setting.appearance.appFontSize)
        }
        .navigationTitle(SettingCategory.appearance.display)
        .formStyle(.grouped)
    }
}


#Preview {
    AppearanceSettingView()
}
