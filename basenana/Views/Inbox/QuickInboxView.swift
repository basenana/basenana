//
//  File.swift
//  basenana
//
//  Created by Hypo on 2024/3/3.
//

import Foundation
import SwiftUI


struct QuickInboxView: View{
    
    @State private var urlInput: String = ""
    @State private var urlTitle: String = ""
    @State private var errorMsg: String = ""
    @State private var fileTypeOption = "webarchive"
    @State private var selectedURL: String? = nil
    @State private var htmlContent: String = ""
    @State private var page: WebPage? = nil
    @State private var showPreview: Bool = false

    @Environment(Store.self) private var store: Store
    
    var body: some View{
        VStack {
            Form{
                TextField("URL", text: $urlInput, onCommit: {
                    if urlInput != ""{
                        if let _ = URL(string: urlInput){
                            Task{
                                do {
                                    let loadedPage = try fetchWebPage(url: urlInput)
                                    self.page = loadedPage
                                    self.urlTitle = loadedPage.title
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
                if let safePage = self.page {
                    Button(action: {
                        self.showPreview = true
                    }) {
                        Text("Preview")
                            .font(.body)
                            .padding(6)
                            .foregroundColor(.white)
                            .background(Color.blue)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                    .popover(isPresented: $showPreview) {
                        VStack {
                            ReadabilityView(page: safePage)
                        }
                        .frame(width: 500, height: 600)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                Button {
                    store.dispatch(.quickInbox(urlStr: urlInput, filename: urlTitle, fileType: fileTypeOption, data: nil ))
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
        .padding(50)
        .frame(minWidth: 600, minHeight: 150)
    }
}


#Preview {
    return QuickInboxView().environment(Store())
}
