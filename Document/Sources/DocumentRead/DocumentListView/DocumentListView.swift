//
//  DocumentListView.swift
//  Entry
//
//  Created by Hypo on 2024/11/16.
//

import SwiftUI
import Foundation
import SwiftUIMasonry
import AppState
import Entities


@available(macOS 14.0, *)
public struct DocumentListView: View {
    @State var viewModel: DocumentListViewModel
    
    public init(viewModel: DocumentListViewModel) {
        self.viewModel = viewModel
    }
    
    public var body: some View {
        VStack {
            ScrollView(.vertical) {
                LazyVStack {
                    ForEach(viewModel.sectionDocuments){ section in
                        DocumentSectionListView(section: section, viewModel: viewModel)
                            .onAppear {
                                viewModel.checkAndLoadNextSection(section)
                            }
                    }
                }
            }
            if viewModel.isLoading {
                Text("☁️Loading ...").padding(.vertical)
            }
        }
        .task {
            viewModel.initNextPage()
        }
        .toolbar(removing: .sidebarToggle)
        .frame(minWidth: 300, idealWidth: 300)
        .navigationTitle(viewModel.prespective.Title)
    }
}


#if DEBUG

import DomainTestHelpers

#Preview {
    if #available(macOS 14.0, *) {
        DocumentListView(viewModel: DocumentListViewModel(prespective: .unread, store: StateStore.empty, usecase: MockDocumentUseCase()))
    }
}

#endif
