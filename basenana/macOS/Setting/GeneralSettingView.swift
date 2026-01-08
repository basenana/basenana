//
//  GeneralSettingView.swift
//  basenana
//
//  Created by Hypo on 2024/12/13.
//

import Foundation
import SwiftUI
import Domain


struct GeneralSettingView: View {
    @State private var state = StateStore.shared

    public var body: some View {
        Form {
            Section("Inbox"){
                Picker("File Type", selection: $state.setting.general.inboxFileType) {
                    Text("WebArchive").tag("webarchive")
                    Text("HTML").tag("html")
                }
                .pickerStyle(.menu)
            }
        }
        .navigationTitle(SettingCategory.general.display)
        .formStyle(.grouped)
    }
}

