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
                    Button(action: {
                        viewModel.store.dispatch(.gotoDestination(.readDocument(document: document.id)))
                    }){
                        DocumentItemView(doc: document, viewModel: viewModel)
                            .frame(maxWidth: 350)
                    }
                    .buttonStyle(.link)
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
