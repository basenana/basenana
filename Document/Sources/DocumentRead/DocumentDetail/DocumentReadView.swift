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
    @State var viewModel: DocumentReadViewModel
    
    public init(viewModel: DocumentReadViewModel) {
        self.viewModel = viewModel
    }
    
    public var body: some View {
        VStack {
            if let detailDocument = viewModel.document {
                HTMLStringView(url: viewModel.targetURL, htmlContent: detailDocument.content)
            }else {
                EmptyView()
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .updateDocumentMark)) { [self] notification in
            if let update = notification.object as? UpdateDocumentMark {
                if update.doc.id != viewModel.docID {
                    return
                }
                Task {
                    if update.updateRead {
                    }
                    if update.updateMark {
                    }
                }
            }
        }
        .navigationTitle(viewModel.document?.name ?? "")
        .frame(minWidth: 200, minHeight: 100)
        .toolbar{
            ToolbarItemGroup(placement: .primaryAction){
                DocumentToolBarView(viewModel: viewModel)
            }
        }
        .task {
            await viewModel.loadDocument()
        }
    }
}


#if DEBUG

import DomainTestHelpers

#Preview {
    if #available(macOS 14.0, *) {
        DocumentReadView(viewModel: DocumentReadViewModel(docID: 1001, store: StateStore.empty, usecase: MockDocumentUseCase()))
    }
}

#endif
