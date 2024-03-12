//
//  File.swift
//  basenana
//
//  Created by Hypo on 2024/3/3.
//

import Foundation
import SwiftUI


struct QuickInboxView: View{
    @Environment(\.modelContext) private var context

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
        var newEntry = EntryModel(id: genEntryID(), name: urlStr, parent: 1, kind: "group")
        context.insert(newEntry)
        do {
            try context.save()
        } catch {
            debugPrint("insert entry to inbox failed")
        }
        return
    }
}

//#Preview {
//    QuickInboxView(isShowingQuickInbox: null).environmentObject(EntryService())
//}
