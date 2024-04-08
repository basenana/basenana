//
//  File.swift
//  basenana
//
//  Created by Hypo on 2024/3/3.
//

import Foundation
import SwiftUI


struct QuickInboxView: View{
    @EnvironmentObject private var entryService: EntryService

    @Binding var isShowingQuickInbox: Bool
    @State private var urlInput: String = ""
    @State private var fileTypeOption = "webarchive"
    @State private var isClutterFree = true
    
    var body: some View{
        Form{
            Section() {
                Text("Save Web Page to Inbox")
                                .font(.title2)
                TextField("URL", text: $urlInput)
                
                Picker("File", selection: $fileTypeOption) {
                    Text("Webarchive").tag("webarchive")
                    Text("Html").tag("html")
                    Text("Bookmark").tag("bookmark")
                }
                Toggle("Clutter Free", isOn: $isClutterFree)
            }
            .padding(.horizontal, 50.0)
            .padding(.top, 20)
            .textFieldStyle(RoundedBorderTextFieldStyle())
            .frame(minWidth: 400, maxWidth: .infinity, minHeight: 20)
            HStack {
                Button("Cancel") {
                    isShowingQuickInbox = false
                }
                
                Button("Submit") {
                    quickInbox(urlStr: urlInput, fileType: fileTypeOption, isClusterFree: isClutterFree)
                    isShowingQuickInbox = false
                }
                .buttonStyle(.borderedProminent)
            }.padding()
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
                Text("Save Document")
                                .font(.title2)
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

//#Preview {
//    QuickInboxView(isShowingQuickInbox: null).environmentObject(EntryService())
//}
