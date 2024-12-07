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
                    Text("☁️Loading ...")
                        .padding(.vertical)
                        .onAppear{
                            NotificationCenter.default.post(name: .loadMoreDocuments, object: nil)
                        }
                }
            }
            .frame(minWidth: 300)
            .toolbar(removing: .sidebarToggle)
            
            if let doc = selection {
                DocumentReadView(viewModel: DocumentReadViewModel(docID: doc.id, store: viewModel.store, usecase: viewModel.usecase)).id(doc.id)
            }
        }
    }
}
