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
    
    @State private var isLoading: Bool = false
    @State private var page: Int = 1
    private let pageSize: Int = 20
    
    var body: some View {
        NavigationSplitView{
            List(docs, id: \.id, selection: $selectedId) { document in
                VStack {
                    
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
                    
                    if self.isLoading && self.docs.isLastItem(document) {
                        Divider()
                        Text("Loading ...")
                            .padding(.vertical)
                    }
                }
                .onAppear{
                    Task.detached{
                        self.listItemAppears(document)
                    }
                }
            }
            .frame(minWidth: 300, idealWidth: 300)
            .onAppear{
                Task.detached{
                    loadNextPageDocuments()
                }
            }
            .listStyle(.inset)
        }detail: {
        }
    }
    
    private func listItemAppears<Item: Identifiable>(_ item: Item) {
        if docs.isLastItem(item) {
            isLoading = true
            
            DispatchQueue(label: "org.basenana.room.listDocuments").async {
                loadNextPageDocuments()
                self.isLoading = false
            }
        }
    }

    private func loadNextPageDocuments() {
        let moreDocs = documentService.listDocuments(
            filter: Docfilter(marked: true),
            order: DocumentOrder(order: DocOrder.createAt, desc: true),
            pages: Pagination(page: Int64(self.page), pageSize: Int64(self.pageSize))
        )
        for doc in moreDocs {
            docMaps[doc.id] = doc
        }
        self.docs.append(contentsOf: moreDocs)
        self.page += 1
    }
}

