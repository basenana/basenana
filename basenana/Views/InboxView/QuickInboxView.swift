//
//  File.swift
//  basenana
//
//  Created by Hypo on 2024/3/3.
//

import Foundation
import SwiftUI


struct QuickInboxView: View{
    
    @Binding var showQuickInbox: Bool
    @Binding var refreshToggle: Bool
    
    @State private var urlInput: String = ""
    @State private var urlTitle: String = ""
    @State private var errorMsg: String = ""
    @State private var fileTypeOption = "webarchive"
    @State private var selectedURL: String? = nil
    
    @State private var htmlContent: String = ""
    
    var body: some View{
        Form{
            VStack {
                VStack(alignment: .leading){
                    TextField("URL", text: $urlInput, onCommit: {
                        if urlInput != ""{
                            if let safeUrl = URL(string: urlInput){
                                Task{
                                    do {
                                        let rp = ReadablePage(url: safeUrl)
                                        try await rp.parse()
                                        urlTitle = rp.urlTitle
                                        htmlContent = rp.htmlContent
                                    }catch {
                                        errorMsg = "fetch web page failed \(error)"
                                    }
                                }
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
                        quickInbox(urlStr: urlInput, filename: urlTitle, fileType: fileTypeOption)
                        showQuickInbox = false
                        refreshToggle.toggle()
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
    
    func quickInbox(urlStr: String, filename: String, fileType: String) {
        Task.detached{
            var data: Data? = nil
            if let url = URL(string: urlStr){
                if htmlContent != ""{
                    switch fileType {
                    case "html":
                        data = htmlContent.data(using: .utf8)
                    case "webarchive":
                        data = webarchiveBaseMainResource(url: url, mainResource: htmlContent)
                    default: break
                    }
                }
                entryService.quickInbox(urlStr: urlStr, filename: filename, fileType: fileType, data: data)
            }
        }
    }
}

#Preview {
    return QuickInboxView(showQuickInbox: .constant(true), refreshToggle: .constant(false))
}
