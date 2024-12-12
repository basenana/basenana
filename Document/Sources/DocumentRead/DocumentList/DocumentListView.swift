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


public struct DocumentListView: View {
    @State var listViewKind: ListViewKind
    @State var viewModel: DocumentListViewModel
    
    public init(viewModel: DocumentListViewModel) {
        self.viewModel = viewModel
        if viewModel.prespective == .marked {
            self.listViewKind = .Navigation
        }else {
            self.listViewKind = .Masonry
        }
    }
    
    public var body: some View {
        VStack {
            switch listViewKind {
            case .Masonry:
                MasonryListView(viewModel: viewModel)
            case .Navigation:
                NavigationListView(viewModel: viewModel)
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .openDocument)) { [self] notification in
            if let document = notification.object as? DocumentItem {
                Task {
                    if document.isUnread {
                        document.isUnread = false
                        await viewModel.setDocumentReadStatus(document: document.id, isUnread: false)
                    }
                }
                gotoDestination(.readDocument(document: document.id))
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .updateDocumentMark)) { [self] notification in
            if let update = notification.object as? UpdateDocumentMark {
                Task {
                    if update.updateRead {
                        await viewModel.setDocumentReadStatus(document: update.doc, isUnread: update.isUnread)
                    }
                    if update.updateMark {
                        await viewModel.setDocumentMarkStatus(document: update.doc, isMark: update.isMarked)
                    }
                }
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .loadMoreDocuments)) { _ in
            Task {
                await viewModel.loadNextPage()
                await viewModel.setAllAppearedDocuemntRead()
            }
        }
        .onAppear { viewModel.reset() }
        .onDisappear{ viewModel.disableHooks() }
        .toolbar {
            ToolbarItemGroup(placement: .navigation) {
                if listViewKind == .Masonry {
                    Button(action: {
                        listViewKind = .Navigation
                    }) {
                        Image(systemName: "list.bullet")
                    }
                }
                
                if listViewKind == .Navigation {
                    Button(action: {
                        listViewKind = .Masonry
                    }) {
                        Image(systemName: "square.grid.2x2")
                    }
                }
            }
        }
        .frame(minWidth: 300, idealWidth: 300)
        .navigationTitle(viewModel.prespective.Title)
    }
}

struct LoadingView: View {
    var body: some View {
        HStack(alignment: .center){
            Spacer()
            Text("☁️Loading ...")
                .padding(.vertical)
                .onAppear{
                    NotificationCenter.default.post(name: .loadMoreDocuments, object: nil)
                }
            Spacer()
        }
    }
}


enum ListViewKind {
    case Masonry
    case Navigation
}


#if DEBUG

import DomainTestHelpers

#Preview {
    if #available(macOS 14.0, *) {
        DocumentListView(viewModel: DocumentListViewModel(prespective: .unread, store: StateStore.empty, usecase: MockDocumentUseCase()))
    }
}

#endif
