//
//  DocumentSettingView.swift
//  basenana
//
//  Created by Hypo on 2024/12/13.
//

import Foundation
import SwiftUI
import Domain


struct DocumentSettingView: View {
    @State private var state = StateStore.shared

    public var body: some View {
        Form {
            Section("Unread List"){
                Picker("Unread List Sort", selection: $state.setting.document.sortUnread) {
                    Text("Newest").tag("newest")
                    Text("Oldest").tag("oldest")
                }
                .pickerStyle(.segmented)
                
                Picker("Group By", selection: $state.setting.document.groupBy) {
                    Text("Date").tag("date")
                    Text("Group").tag("group")
                }
                .pickerStyle(.segmented)

                LabeledContent {
                    Toggle("Auto Read", isOn: $state.setting.document.autoRead)
                        .toggleStyle(.switch)
                        .labelsHidden()
                } label: {
                    Text("Auto Read")
                }
            }
            
            Section("Enhance"){
                LabeledContent {
                    Toggle("Translate", isOn: $state.setting.document.autoTranslate)
                        .toggleStyle(.switch)
                        .labelsHidden()
                        .disabled(true)
                } label: {
                    Text("Translate")
                    Text("Coming")
                }
                LabeledContent {
                    Toggle("Summary", isOn: $state.setting.document.autoSummary)
                        .toggleStyle(.switch)
                        .labelsHidden()
                        .disabled(true)
                } label: {
                    Text("Summary")
                    Text("Coming")
                }
            }
        }
        .navigationTitle(SettingCategory.document.display)
        .formStyle(.grouped)
    }
}

