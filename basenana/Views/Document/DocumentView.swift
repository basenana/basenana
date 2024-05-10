//
//  DocumentView.swift
//  basenana
//
//  Created by Hypo on 2024/3/2.
//

import Foundation
import SwiftUI


struct DocumentView: View {
    @State private var docs: [DocumentModel] = []
    @State private var docMaps: [Int64:DocumentModel] = [:]
    @State private var selectedId: Int64? = 0
    
    var body: some View {
        NavigationView{
            List(docs, id: \.id, selection: $selectedId) { document in
                let selected = docMaps[selectedId!]
                NavigationLink {
                    DocumentDetailView(doc: selected)
                } label: {
                    // document items
                    DocumentItemView(doc: document)
                }
            }
            .frame(minWidth: 300, idealWidth: 300)
            .onAppear{
                docs = documentService.listDocuments()
                for doc in docs {
                    docMaps[doc.id] = doc
                }
            }
            .onChange(of: selectedId) {
                documentService.readDocument(docId: selectedId!, unread: false)
                let selected = docMaps[selectedId!]
                if let index = docs.firstIndex(of: selected!) {
                    self.docs[index].unread = false
                }
            }
        }
    }
}


#Preview {
    return DocumentView()
}
