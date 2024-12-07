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
                            NotificationCenter.default.post(name: .openDocument, object: document)
                        }){
                            MasonryItemView(section: section.id, doc: document, viewModel: viewModel)
                                .onAppear { viewModel.onDocumentAppear(document: document) }
                                .onDisappear { viewModel.onDocumentDisappear(document: document) }
                                .padding(.vertical, 20)
                                .frame(maxWidth: 350)
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
