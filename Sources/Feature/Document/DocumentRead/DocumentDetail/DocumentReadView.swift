//
//  DocumentReadView.swift
//  Document
//
//  Created by Hypo on 2024/11/18.
//

import SwiftUI
import Domain


public struct DocumentReadView: View {
    @State var document: EntryDetail? = nil
    @State var viewModel: DocumentReadViewModel
    @State var isUnread: Bool = false
    @State var isMarked: Bool = false


    public init(viewModel: DocumentReadViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        VStack {
            if viewModel.isLoading {
                Text("Loading")
                    .font(.title)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if let fileURL = viewModel.cachedFileURL {
                HTMLStringView(fileURL: fileURL)
            } else if let error = viewModel.errorMessage {
                Text(error)
                    .foregroundColor(.red)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                EmptyView()
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .updateDocumentMark)) { [self] notification in
            if let update = notification.object as? UpdateDocumentMark {
                if update.uri != viewModel.uri {
                    return
                }
                if update.updateRead {
                    isUnread = update.isUnread
                }
                if update.updateMark {
                    isMarked = update.isMarked
                }
            }
        }
        .navigationTitle(document?.name ?? "")
        .frame(minWidth: 200, minHeight: 100)
        .toolbar{
            if document != nil {
                ToolbarItemGroup(placement: .primaryAction){
                    DocumentToolBarView(viewModel: viewModel, isUnread: $isUnread, isMarked: $isMarked)
                }
            }
        }
        .task {
            await viewModel.loadDocument()
            if let document = viewModel.entry {
                isUnread = document.documentUnread
                isMarked = document.documentMarked
            }
        }
    }
}
