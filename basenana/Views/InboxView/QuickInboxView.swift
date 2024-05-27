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
    
    @Binding var showQuickInbox: Bool
    
    @State private var urlInput: String = ""
    @State private var urlTitle: String = ""
    @State private var errorMsg: String = ""
    @State private var fileTypeOption = "webarchive"
    @State private var isClutterFree = true
    @State private var selectedURL: String? = nil
    
    var body: some View{
        Form{
            VStack {
                VStack(alignment: .leading){
                    TextField("URL", text: $urlInput, onCommit: {
                        if urlInput != ""{
                            do {
                                urlTitle = try parseURLTitle(urlStr: urlInput)
                            }catch {
                                errorMsg = "fetch web page failed \(error)"
                            }
                        }
                    })
                    .textFieldStyle(.squareBorder)
                    .padding(.vertical, 5)
                    
                    TextField("Title", text: $urlTitle)
                        .textFieldStyle(.squareBorder)
                        .padding(.vertical, 5)
                    
                    Picker("Flile Type", selection: $fileTypeOption) {
                        Text("Webarchive").tag("webarchive")
                        Text("Html").tag("html")
                        Text("Bookmark").tag("bookmark")
                    }
                    .pickerStyle(.inline)
                    .padding(.vertical, 5)
                    
                    Toggle("Clutter-Free", isOn: $isClutterFree)
                        .toggleStyle(.switch)
                        .padding(.vertical, 5)
                }
                
                HStack {
                    if errorMsg != ""{
                        Text("\(errorMsg)")
                            .foregroundStyle(.red)
                            .padding(.vertical, 5)
                    }
                    Button {
                        if urlTitle == ""{
                            urlTitle = (try? parseURLTitle(urlStr: urlInput)) ?? "unknown"
                        }
                        quickInbox(urlStr: urlInput, filename: urlTitle, fileType: fileTypeOption, isClusterFree: isClutterFree)
                        showQuickInbox = false
                    } label: {
                        Text("Inbox")
                            .font(.body)
                            .padding(6)
                            .foregroundColor(.white)
                            .background(Color.blue)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                .frame(maxWidth: .infinity, alignment: .trailing)
                .padding(.vertical, 10)
            }
            .padding(20)
        }
        .formStyle(.grouped)
    }
    
    func quickInbox(urlStr: String, filename: String, fileType: String, isClusterFree:Bool) {
        Task.detached{
            entryService.quickInbox(urlStr: urlStr, filename: filename, fileType: fileType, isClusterFree: isClusterFree)
        }
    }
}

#Preview {
    return QuickInboxView(showQuickInbox: .constant(true))
}
