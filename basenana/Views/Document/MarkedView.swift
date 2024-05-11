//
//  MarkView.swift
//  basenana
//
//  Created by zww on 2024/5/11.
//

import Foundation
import SwiftUI

struct MarkedView: View {
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
                        DocumentItemView(doc: document, unreadPage: false)
                    }
                }
            }
            .frame(minWidth: 300, idealWidth: 300)
            .onAppear{
                docs = documentService.listDocuments(filter: Docfilter(marked: true))
                for doc in docs {
                    docMaps[doc.id] = doc
                }
            }
        }
    }
}

