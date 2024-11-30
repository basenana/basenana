//
//  DocumentReadView.swift
//  Document
//
//  Created by Hypo on 2024/11/18.
//

import SwiftUI
import AppState
import Entities


@available(macOS 14.0, *)
public struct DocumentReadView: View {
    var viewModel: DocumentReadViewModel
    
    public init(viewModel: DocumentReadViewModel) {
        self.viewModel = viewModel
    }
    
    public var body: some View {
        VStack {
            if let detailDocument = viewModel.document {
                HTMLView(document: detailDocument)
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
