//
//  WebPackInboxView.swift
//  Entry
//
//  Created by Hypo on 2024/12/1.
//

import SwiftUI
import WebKit
import Foundation
import AppState
import Entities
import WebPage


public struct WebPackInboxView: View {
    private var viewModel: InboxViewModel
    private var webView: WKWebView
    
    @State private var urlInput: String = ""
    @State private var urlTitle: String = ""
    @State private var showPreview: Bool = false
    @State private var page: WebPage? = nil
    @State private var errorMessage: String = ""
    @State private var isInboxing: Bool = false
    
    @State private var htmlMainResource = ""
    
    init(viewModel: InboxViewModel) {
        self.viewModel = viewModel
        self.webView = WKWebView(frame: CGRect.zero, configuration: WKWebViewConfiguration())
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
                
                if let safePage = self.page {
                    InboxPreviewView(page: safePage, webView: webView)
                        .frame(width: 500, height: 600)
                }
                
            }
            HStack {
                if errorMessage != ""{
                    Text("\(errorMessage)")
                        .foregroundStyle(.red)
                        .padding(.vertical, 5)
                }
                
                // inbox
                Button {
                    Task {
                        await inbox()
                    }
                } label: {
                    Text("Inbox")
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
        defer {
            isInboxing = false
        }
        let (errMsg, isSucc) = await viewModel.packingWebPage(url: urlInput, title: urlTitle, webView: webView)
        if isSucc {
            viewModel.showQuickInbox.toggle()
        }
        errorMessage = errMsg
    }
    
    func tryLoadWebPage() {
        let urlStr = urlInput
        guard urlStr != "" else {
            return
        }
        isInboxing = true
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
                isInboxing = false
            }
        }
    }
}


#if DEBUG

import DomainTestHelpers

#Preview {
    WebPackInboxView(viewModel: InboxViewModel(store: StateStore.empty, entryUsecase: MockEntryUseCase()))
}

#endif
