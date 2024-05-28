//
//  DocumentView.swift
//  basenana
//
//  Created by Hypo on 2024/3/2.
//

import Foundation
import SwiftUI


struct UnreadView: View {
    @State private var docs: [DocumentInfoModel] = []
    @State private var docMaps: [Int64:DocumentInfoModel] = [:]
    @State private var selectedId: Int64? = 0
    
    var body: some View {
        NavigationSplitView{
            List(docs, id: \.id, selection: $selectedId) { document in
                if let docId = selectedId {
                    NavigationLink {
                        if let selected = docMaps[docId] {
                            DocumentDetailView(entryId: selected.oid)
                        }
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
                Task.detached{
                    docs = documentService.listDocuments(filter: Docfilter(unread: true), order: DocumentOrder(order: DocOrder.createAt, desc: true))
                    for doc in docs {
                        docMaps[doc.id] = doc
                    }
                }
            }
            .onChange(of: selectedId) {
                Task.detached{
                    documentService.updateDocument(docUpdate: DocumentUpdate(docId: selectedId!, unread: false))
                    let selected = docMaps[selectedId!]
                    if let index = docs.firstIndex(of: selected!) {
                        self.docs[index].unread = false
                    }
                }
            }
            .listStyle(.inset)
        } detail: {
            
        }
    }
}


#Preview {
    return UnreadView()
}
