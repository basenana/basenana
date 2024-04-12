//
//  File.swift
//  basenana
//
//  Created by Hypo on 2024/3/3.
//

import Foundation
import SwiftUI
import SwiftData


struct QuickInboxView: View{
    @EnvironmentObject private var entryService: EntryService
    
    @Binding var isShowingQuickInbox: Bool
    @State private var urlInput: String = ""
    @State private var fileTypeOption = "webarchive"
    @State private var isClutterFree = true
    
    var body: some View{
        Form{
            Section() {
                Text("Save Web Page to Inbox").font(.title2)
                
                TextField("URL", text: $urlInput)
                
                Picker("File", selection: $fileTypeOption) {
                    Text("Webarchive").tag("webarchive")
                    Text("Html").tag("html")
                    Text("Bookmark").tag("bookmark")
                }
                Toggle("Clutter Free", isOn: $isClutterFree)
            }
            .padding(.horizontal, 50.0)
            .padding(10)
            .textFieldStyle(RoundedBorderTextFieldStyle())
            .frame(minWidth: 400, maxWidth: .infinity, minHeight: 20)
            
            HStack {
                Button {
                    isShowingQuickInbox = false
                } label: {
                    Text("Cancel")
                        .font(.body)
                        .padding(6)
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }
                .buttonStyle(PlainButtonStyle())
                
                Spacer()
                
                Button {
                    quickInbox(urlStr: urlInput, fileType: fileTypeOption, isClusterFree: isClutterFree)
                    isShowingQuickInbox = false
                } label: {
                    Text("Submit")
                        .font(.body)
                        .padding(6)
                        .foregroundColor(.white)
                        .background(Color.blue)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }
                .buttonStyle(PlainButtonStyle())
            }
            .padding(.horizontal, 50.0)
        }
        .formStyle(.grouped)
        .padding()
    }
    
    func quickInbox(urlStr: String, fileType: String, isClusterFree:Bool) {
        entryService.quickInbox(urlStr: urlStr, fileType: fileType, isClusterFree: isClusterFree)
        entryService.reflush()
    }
}

struct QuickDocumentView: View{
    @EnvironmentObject private var docService: DocumentService
    
    @Binding var isShowingQuickDocument: Bool
    @State private var title: String = ""
    @State private var content: String = ""
    
    var body: some View{
        Form{
            Section() {
                Text("Save Document").font(.title2)
                TextField("Title", text: $title)
                TextField("content", text: $content)
                
            }
            .padding(.horizontal, 50.0)
            .padding(.top, 20)
            .textFieldStyle(RoundedBorderTextFieldStyle())
            .frame(minWidth: 400, maxWidth: .infinity, minHeight: 20)
            HStack {
                Button("Cancel") {
                    isShowingQuickDocument = false
                }
                
                Button("Submit") {
                    quickInbox()
                    isShowingQuickDocument = false
                }
                .buttonStyle(.borderedProminent)
            }.padding()
        }
        .formStyle(.grouped)
        .padding()
    }
    
    func quickInbox() {
        docService.saveDocument(name:title, content: content)
        docService.reflush()
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: EntryModel.self, configurations: config)
    
    return QuickInboxView(isShowingQuickInbox: .constant(true)).environmentObject(EntryService(modelContext: container.mainContext))
}
