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
                        .padding(.horizontal, 20)
                }
                LazyVStack {
                    if viewModel.hasMore {
                        LoadingView()
                    } else {
                        MasonryListReadAllView(viewModel: viewModel)
                    }
                }
            }
        }
        .toolbar(removing: .sidebarToggle)
        .frame(minWidth: 300, idealWidth: 300)
        .navigationTitle(viewModel.prespective.Title)
    }
}

struct MasonryListReadAllView: View {
    @State var viewModel: DocumentListViewModel
    @State var hasUnread: Bool = false
    
    public init(viewModel: DocumentListViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        Divider()
        HStack(alignment: .center){
            if hasUnread {
                Spacer()
                Button(action: {
                    Task {
                        await viewModel.setAllAppearedDocuemntRead(before: 0, isAuto: false)
                        hasUnread = false
                    }
                }, label: {
                    Label("Make All as Read", systemImage: "checkmark.rectangle.stack")
                })
                .buttonStyle(.borderless)
                .padding(.vertical)
                Spacer()
            }
        }
        .task {
            for sectionDocument in viewModel.sectionDocuments.reversed() {
                for document in sectionDocument.documents {
                    if document.isUnread {
                        hasUnread = true
                    }
                }
            }
        }
    }
}


#if DEBUG

import DomainTestHelpers

#Preview {
    MasonryListView(viewModel: DocumentListViewModel(prespective: .unread, store: StateStore.shared, usecase: MockDocumentUseCase()))
}

#endif
