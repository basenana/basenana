//
//  NavigationListView.swift
//  Document
//
//  Created by Hypo on 2024/12/7.
//

import SwiftUI
import Foundation
import SwiftUIMasonry
import Domain
import Domain


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
                DocumentReadView(viewModel: DocumentReadViewModel(uri: doc.uri, store: viewModel.store, usecase: viewModel.usecase))
                    .task {
                        if doc.isUnread {
                            doc.isUnread.toggle()
                            NotificationCenter.default.post(name: .updateDocumentMark, object: UpdateDocumentMark(uri: doc.uri, isUnread: false))
                        }
                    }.id(doc.uri)
            }
        }
    }
}
