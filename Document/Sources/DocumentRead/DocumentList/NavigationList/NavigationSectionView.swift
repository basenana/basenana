//
//  NavigationSectionView.swift
//  Document
//
//  Created by Hypo on 2024/12/7.
//

import SwiftUI
import Foundation
import SwiftUIMasonry
import AppState
import Entities


struct DocumentListSectionView: View {
    @State var section: DocumentSection
    @State var viewModel: DocumentListViewModel
    
    init(section: DocumentSection, viewModel: DocumentListViewModel) {
        self.section = section
        self.viewModel = viewModel
    }
    
    var body: some View {
        Section(section.id){
            ForEach(section.documents){ document in
                NavigationLink(value: document) {
                    NavigationItemView(section: section.id, doc: document, viewModel: viewModel)
                }
            }
        }
    }
}
