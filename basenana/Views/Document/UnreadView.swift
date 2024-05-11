//
//  DocumentView.swift
//  basenana
//
//  Created by Hypo on 2024/3/2.
//

import Foundation
import SwiftUI


struct UnreadView: View {
    @State private var docs: [DocumentModel] = []
    @State private var docMaps: [Int64:DocumentModel] = [:]
    @State private var selectedId: Int64? = 0
    
    var body: some View {
        NavigationView{
            List(docs, id: \.id, selection: $selectedId) { document in
                if let docId = selectedId {
                    let selected = docMaps[docId]
                    NavigationLink {
                        DocumentDetailView(doc: selected)
                    } label: {
                        // document items
                        DocumentItemView(doc: document, unreadPage: true)
                    }
                }
            }
            .contextMenu{
                Button("Mark") {
                    documentService.updateDocument(docUpdate: DocumentUpdate(docId: selectedId!, marked: true))
                }
            }
            .frame(minWidth: 300, idealWidth: 300)
            .onAppear{
                docs = documentService.listDocuments(filter: Docfilter(unread: true))
                for doc in docs {
                    docMaps[doc.id] = doc
                }
            }
            .onChange(of: selectedId) {
                documentService.updateDocument(docUpdate: DocumentUpdate(docId: selectedId!, unread: false))
                let selected = docMaps[selectedId!]
                if let index = docs.firstIndex(of: selected!) {
                    self.docs[index].unread = false
                }
            }
        }
    }
}


#Preview {
    return UnreadView()
}
