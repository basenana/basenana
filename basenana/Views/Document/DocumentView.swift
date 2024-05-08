//
//  DocumentView.swift
//  basenana
//
//  Created by Hypo on 2024/3/2.
//

import Foundation
import SwiftUI


struct DocumentView: View {
    @State private var selectedItem: DocumentModel? = nil
    @State private var docs: [DocumentModel] = []
    
    var body: some View {
        NavigationView{
            List(docs, id: \.self, selection: $selectedItem) { document in
                NavigationLink {
                    DocumentDetailView(doc: selectedItem)
                } label: {
                    // document items
                    DocumentItemView(doc: document)
                }
            }
            .frame(minWidth: 300, idealWidth: 300)
            .onAppear{
                docs = documentService.listDocuments()
            }
        }
    }
}


#Preview {
    return DocumentView()
}
