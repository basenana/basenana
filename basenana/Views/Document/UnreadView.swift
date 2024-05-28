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
    
    @State private var isLoading: Bool = false
    @State private var page: Int = 1
    private let pageSize: Int = 20
    
    var body: some View {
        NavigationSplitView{
            List(docs, id: \.id, selection: $selectedId) { document in
                VStack{
                    
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
            .contextMenu{
                Button("Mark") {
                    documentService.updateDocument(docUpdate: DocumentUpdate(docId: selectedId!, marked: true))
                }
            }
            .frame(minWidth: 300, idealWidth: 300)
            .onAppear{
                Task.detached{
                    loadNextPageDocuments()
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
            filter: Docfilter(unread: true),
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


#Preview {
    return UnreadView()
}
