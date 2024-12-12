//
//  NavigationListView.swift
//  Document
//
//  Created by Hypo on 2024/12/7.
//

import SwiftUI
import Foundation
import SwiftUIMasonry
import AppState
import Entities


public struct NavigationListView: View {
    @State var viewModel: DocumentListViewModel
    @State var selection: DocumentItem?
    
    public init(viewModel: DocumentListViewModel) {
        self.viewModel = viewModel
    }
    
    public var body: some View {
        NavigationView() {
            List(selection: $selection) {
                ForEach(viewModel.sectionDocuments){ section in
                    DocumentListSectionView(section: section, viewModel: viewModel)
                }
                if viewModel.hasMore {
                    LoadingView()
                }
            }
            .frame(minWidth: 300)
            .toolbar(removing: .sidebarToggle)
            
            if let doc = selection {
                DocumentReadView(viewModel: DocumentReadViewModel(docID: doc.id, store: viewModel.store, usecase: viewModel.usecase))
                    .task {
                        if doc.isUnread {
                            doc.isUnread.toggle()
                            NotificationCenter.default.post(name: .updateDocumentMark, object: UpdateDocumentMark(doc: doc.id, isUnread: false))
                        }
                    }.id(doc.id)
            }
        }
    }
}
