//
//  ReadingSettingView.swift
//  basenana
//
//  Created by Hypo on 2024/12/13.
//

import Foundation
import SwiftUI
import AppState


struct ReadingSettingView: View {
    @State private var state = StateStore.shared
    @State private var documentFontSize: Double = 1
    @State private var documentLetterSpacing: Double = 10
    @State private var documentMaxWidth: Double = 1
    @State private var documentTitleFontSize: Double = 2
    
    var body: some View {
        Form {
            Section("Document Content"){
                Picker("Font", selection: $state.setting.reading.documentFont) {
                    Text("Default").tag("default")
                }
                .pickerStyle(.menu)
                
                LabeledContent {
                    Slider(
                        value: $documentFontSize,
                        in: 1...5,
                        step: 1,
                        onEditingChanged: { editing in
                            state.setting.reading.documentFontSize = Int(documentFontSize)
                        }
                    )
                } label: {
                    Text("Font Size")
                    Text("x\(Int(documentFontSize))")
                }

                LabeledContent {
                    Slider(
                        value: $documentLetterSpacing,
                        in: -5...5,
                        step: 1,
                        onEditingChanged: { editing in
                            state.setting.reading.documentLetterSpacing = Int(documentLetterSpacing)
                        }
                    )
                } label: {
                    Text("Letter Spacing")
                    Text("x\(Int(documentLetterSpacing))")
                }

                LabeledContent {
                    Slider(
                        value: $documentMaxWidth,
                        in: -5...5,
                        step: 1,
                        onEditingChanged: { editing in
                            state.setting.reading.documentMaxWidth = Int(documentMaxWidth)
                        }
                    )
                } label: {
                    Text("Max Width")
                    Text("x\(Int(documentMaxWidth))")
                }

            }
            
            Section("Document Title"){
                LabeledContent {
                    Slider(
                        value: $documentTitleFontSize,
                        in: 1...10,
                        step: 1,
                        onEditingChanged: { editing in
                            state.setting.reading.documentTitleFontSize = Int(documentTitleFontSize)
                        }
                    )
                } label: {
                    Text("Font Size")
                    Text("x\(Int(documentTitleFontSize))")
                }
                
                Picker("Align", selection: $state.setting.reading.documentTitleAlign) {
                    Text("Left").tag("left")
                    Text("Centre").tag("centre")
                }
                .pickerStyle(.segmented)
                
                Toggle("Bold", isOn: $state.setting.reading.documentTitleBold)
                    .toggleStyle(.switch)
            }
            
            Section("Custom CSS"){
                TextEditor(text: $state.setting.reading.documentCustomCSS)
                    .frame(minHeight: 100)
            }
            
        }
        .onAppear{
            documentFontSize = Double(state.setting.reading.documentFontSize)
            documentLetterSpacing = Double(state.setting.reading.documentLetterSpacing)
            documentMaxWidth = Double(state.setting.reading.documentMaxWidth)
            documentTitleFontSize = Double(state.setting.reading.documentTitleFontSize)
        }
        .navigationTitle(SettingCategory.reading.display)
        .formStyle(.grouped)
    }
}

