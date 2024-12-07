//
//  MasonrySectionView.swift
//  Document
//
//  Created by Hypo on 2024/12/4.
//


import SwiftUI
import Foundation
import SwiftUIMasonry
import AppState
import Entities


struct MasonrySectionView: View {
    @State var section: DocumentSection
    @State var viewModel: DocumentListViewModel
    
    init(section: DocumentSection, viewModel: DocumentListViewModel) {
        self.section = section
        self.viewModel = viewModel
    }
    
    var body: some View {
        Section(header: MasonrySectionTitleView(title: section.id) ){
            Masonry(.vertical, lines: .adaptive(minSize: 350), content: {
                ForEach(section.documents){ document in
                    LazyVStack{
                        Button(action: {
                            Task {
                                if document.isUnread {
                                    document.isUnread = false
                                    await viewModel.setDocumentReadStatus(section: section.id, document: document.id, isUnread: false)
                                }
                            }
                            viewModel.store.dispatch(.gotoDestination(.readDocument(document: document.id)))
                        }){
                            MasonryItemView(section: section.id, doc: document, viewModel: viewModel)
                                .frame(maxWidth: 350)
                                .task(priority: .background) {
                                    await viewModel.checkAndLoadNextPage(section.id, document)
                                }
                        }
                        .buttonStyle(.link)
                    }
                }
            })
        }
    }
}


struct MasonrySectionTitleView: View {
    @State var title: String
    var body: some View {
        Text(title)
            .font(.title)
            .fontWeight(.thin)
            .foregroundStyle(.gray)
            .padding(.top, 20)
    }
}
