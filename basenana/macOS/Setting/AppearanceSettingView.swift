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

    var body: some View {
        Form {
            Picker("Setting_ColorScheme_Label", selection: $colorScheme) {
                ForEach(ColorSchemeSetting.allCases) { colorScheme in
                    Text(colorScheme.display)
                        .tag(colorScheme.rawValue)
                }
            }
            .pickerStyle(.segmented)
            
            LabeledContent {
                Toggle("Setting_showBookMark", isOn: $bookMark)
                    .toggleStyle(.switch)
                    .labelsHidden()
            } label: {
                Text("Setting_showBookMark")
                Text("Setting_showBookMark_Description")
            }
        }
        .navigationTitle(SettingCategory.appearance.display)
        .formStyle(.grouped)
    }
}
