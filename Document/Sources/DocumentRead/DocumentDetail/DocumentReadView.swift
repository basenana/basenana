//
//  DocumentReadView.swift
//  Document
//
//  Created by Hypo on 2024/11/18.
//

import SwiftUI
import AppState
import Entities


public struct DocumentReadView: View {
    @State var document: DocumentDetail? = nil
    @State var viewModel: DocumentReadViewModel
    @State var isUnread: Bool = false
    @State var isMarked: Bool = false

    
    public init(viewModel: DocumentReadViewModel) {
        self.viewModel = viewModel
    }
    
    public var body: some View {
        VStack {
            if let detailDocument = document {
                HTMLStringView(url: viewModel.targetURL, htmlContent: detailDocument.content)
            }else {
                EmptyView()
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .updateDocumentMark)) { [self] notification in
            if let update = notification.object as? UpdateDocumentMark {
                if update.doc != viewModel.docID {
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
            document = await viewModel.loadDocument()
            if let document = document {
                isUnread = document.unread
                isMarked = document.marked
            }
        }
    }
}


#if DEBUG

import DomainTestHelpers

#Preview {
    DocumentReadView(viewModel: DocumentReadViewModel(docID: 1001, store: StateStore.empty, usecase: MockDocumentUseCase()))
}

#endif
