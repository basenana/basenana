//
//  DocumentListView.swift
//  Entry
//
//  Created by Hypo on 2024/11/16.
//

import SwiftUI
import Foundation
import SwiftUIMasonry
import Domain
import Domain


public struct DocumentListView: View {
    @State var listViewKind: ListViewKind
    @State var viewModel: DocumentListViewModel
    
    public init(viewModel: DocumentListViewModel) {
        self.viewModel = viewModel
        self.listViewKind = viewModel.getListViewKind()
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
                        await viewModel.setDocumentReadStatus(uri: document.uri, isUnread: false)
                    }
                }
                gotoDestination(.readDocument(uri: document.uri))
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .updateDocumentMark)) { [self] notification in
            if let update = notification.object as? UpdateDocumentMark {
                Task {
                    if update.updateRead {
                        await viewModel.setDocumentReadStatus(uri: update.uri, isUnread: update.isUnread)
                    }
                    if update.updateMark {
                        await viewModel.setDocumentMarkStatus(uri: update.uri, isMark: update.isMarked)
                    }
                }
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .loadMoreDocuments)) { _ in
            Task {
                await viewModel.loadNextPage()
                await viewModel.setAllAppearedDocumentRead()
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
