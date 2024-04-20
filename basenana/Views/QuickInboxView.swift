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
    
    @State private var urlInput: String = ""
    @State private var fileTypeOption = "webarchive"
    @State private var isClutterFree = true
    
    var body: some View{
        Form{
            Section() {
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
            .frame(minWidth: 400, maxWidth: .infinity, maxHeight: .infinity)
            
            HStack {
                Button {
                    quickInbox(urlStr: urlInput, fileType: fileTypeOption, isClusterFree: isClutterFree)
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
            .frame(maxWidth: .infinity, alignment: .trailing)
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
    return QuickInboxView()
}
