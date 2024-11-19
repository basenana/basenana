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


@available(macOS 14.0, *)
public struct InboxView: View {
    private var viewModel: InboxViewModel
    
    @State private var urlInput: String = ""
    @State private var urlTitle: String = ""
    @State private var fileTypeOption = "webarchive"
    @State private var showPreview: Bool = false
    
    init(viewModel: InboxViewModel) {
        self.viewModel = viewModel
    }
    
    public var body: some View {
        VStack {
            Form{
                TextField("URL", text: $urlInput, onCommit: {
                    viewModel.tryLoadWebPage(urlInput: urlInput, urlTitle: $urlTitle)
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
                if viewModel.errorMsg != ""{
                    Text("\(viewModel.errorMsg)")
                        .foregroundStyle(.red)
                        .padding(.vertical, 5)
                }
                
                // preview
                if viewModel.page != nil {
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
                            InboxPreviewView(viewModel: viewModel)
                        }
                        .frame(width: 500, height: 600)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                
                // inbox
                Button {
                    viewModel.doInbox(url: urlInput, title: urlTitle, fileType: fileTypeOption)
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


#if DEBUG

import DomainTestHelpers

#Preview {
    if #available(macOS 14.0, *) {
        InboxView(viewModel: InboxViewModel(store: StateStore.empty, usecase: MockInboxUseCase()))
    }
}

#endif
