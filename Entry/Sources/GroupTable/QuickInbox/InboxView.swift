//
//  InboxView.swift
//  Inbox
//
//  Created by Hypo on 2024/10/14.
//

import SwiftUI
import Foundation
import AppState
import Entities
import WebPage


public struct QuickInboxView: View {
    private var viewModel: TreeViewModel
    
    @State private var urlInput: String = ""
    @State private var urlTitle: String = ""
    @State private var fileTypeOption = "webarchive"
    @State private var showPreview: Bool = false
    @State private var page: WebPage? = nil
    @State private var errorMessage: String = ""
    @State private var isInboxing: Bool = false
    
    init(viewModel: TreeViewModel) {
        self.viewModel = viewModel
    }
    
    public var body: some View {
        VStack {
            Form{
                TextField("URL", text: $urlInput, onCommit: { tryLoadWebPage() })
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
                if errorMessage != ""{
                    Text("\(errorMessage)")
                        .foregroundStyle(.red)
                        .padding(.vertical, 5)
                }
                
                // preview
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
                            InboxPreviewView(page: safePage)
                        }
                        .frame(width: 500, height: 600)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                
                // inbox
                Button {
                    Task {
                        await inbox()
                    }
                } label: {
                    Text(isInboxing ? "..." : "Inbox")
                        .font(.body)
                        .padding(6)
                        .foregroundColor(.white)
                        .background(Color.blue)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        .disabled(isInboxing)
                }
                .buttonStyle(PlainButtonStyle())
            }
            .frame(maxWidth: .infinity, alignment: .trailing)
            .padding(.vertical, 10)
        }
        .padding(50)
        .frame(minWidth: 600, minHeight: 150)
    }
    
    func inbox() async {
        isInboxing = true
        if await viewModel.quickInbox(url: urlInput, title: urlTitle, fileType: fileTypeOption, errorMsg: $errorMessage){
            viewModel.showQuickInbox.toggle()
        }
    }

    func tryLoadWebPage() {
        let urlStr = urlInput
        guard urlStr != "" else {
            return
        }
        errorMessage = ""
        if let _ = URL(string: urlStr){
            Task{
                do {
                    let loadedPage = try fetchWebPage(url: urlStr)
                    self.page = loadedPage
                    urlTitle = self.page?.title ?? ""
                }catch {
                    errorMessage = "fetch web page failed \(error)"
                }
            }
        }
    }
}


#if DEBUG

import DomainTestHelpers

#Preview {
    if #available(macOS 14.0, *) {
        QuickInboxView(viewModel: TreeViewModel(store: StateStore.empty, entryUsecase: MockEntryUseCase()))
    }
}

#endif
