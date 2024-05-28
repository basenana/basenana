//
//  MarkView.swift
//  basenana
//
//  Created by zww on 2024/5/11.
//

import Foundation
import SwiftUI

struct MarkedView: View {
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
                        DocumentItemView(doc: document, unreadPage: false)
                    }
                }
            }
            .frame(minWidth: 300, idealWidth: 300)
            .onAppear{
                Task.detached{
                    docs = documentService.listDocuments(filter: Docfilter(marked: true), order: DocumentOrder(order: DocOrder.createAt, desc: true))
                    for doc in docs {
                        docMaps[doc.id] = doc
                    }
                }
            }
            .listStyle(.inset)
        }detail: {
        }
    }
}

