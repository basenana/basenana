//
//  MasonryListView.swift
//  Document
//
//  Created by Hypo on 2024/12/4.
//

import SwiftUI
import Foundation
import SwiftUIMasonry
import AppState
import Entities


public struct MasonryListView: View {
    @State var viewModel: DocumentListViewModel
    
    public init(viewModel: DocumentListViewModel) {
        self.viewModel = viewModel
    }
    
    public var body: some View {
        VStack {
            ScrollView(.vertical) {
                ForEach(viewModel.sectionDocuments){ section in
                    MasonrySectionView(section: section, viewModel: viewModel)
                }
                LazyVStack {
                    if viewModel.hasMore {
                        LoadingView()
                    }
                }
            }
            .padding(.horizontal, 20)
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
        MasonryListView(viewModel: DocumentListViewModel(prespective: .unread, store: StateStore.empty, usecase: MockDocumentUseCase()))
    }
}

#endif
