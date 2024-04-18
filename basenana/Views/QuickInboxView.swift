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
    }
}

#Preview {
    return QuickInboxView(isShowingQuickInbox: .constant(true))
}
