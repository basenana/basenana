//
//  DocumentSectionListView.swift
//  Document
//
//  Created by Hypo on 2024/11/23.
//

import SwiftUI
import Foundation
import SwiftUIMasonry
import AppState
import Entities


struct DocumentSectionListView: View {
    @State var section: DocumentSection
    @State var viewModel: DocumentListViewModel
    
    init(section: DocumentSection, viewModel: DocumentListViewModel) {
        self.section = section
        self.viewModel = viewModel
    }
    
    var body: some View {
        Section(header: DocumentSectionTitleView(title: section.id) ){
            Masonry(.vertical, lines: .adaptive(minSize: 350), content: {
                ForEach(section.documents){ document in
                    LazyVStack{
                        Button(action: {
                            if document.isUnread {
                                document.isUnread = false
                                viewModel.setDocumentReadStatus(section: section.id, document: document.id, isUnread: false)
                            }
                            viewModel.store.dispatch(.gotoDestination(.readDocument(document: document.id)))
                        }){
                            DocumentItemView(section: section.id, doc: document, viewModel: viewModel)
                                .frame(maxWidth: 350)
                                .onAppear {
                                    viewModel.checkAndLoadNextPage(section.id, document)
                                }
                        }
                        .buttonStyle(.link)
                    }
                }
            })
        }
    }
}


struct DocumentSectionTitleView: View {
    @State var title: String
    var body: some View {
        Text(title)
            .font(.title)
            .fontWeight(.thin)
            .foregroundStyle(.gray)
            .padding(.top, 20)
    }
}
