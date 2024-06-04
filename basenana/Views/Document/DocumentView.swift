//
//  BaseDocumentView.swift
//  basenana
//
//  Created by zww on 2024/6/3.
//

import SwiftUI

struct DocumentView: View {
    var filter: Docfilter
    @Binding var searchEntry: Int64?

    @State private var docs: [DocumentInfoModel] = []
    @State private var docMaps: [Int64:DocumentInfoModel] = [:]
    @State private var selectedId: Int64? = 0
    
    @State private var parentNames: [String] = []
    @State private var parentSelected: String?
    @State private var parentMaps: [String:EntryInfoModel] = [:]
    
    @State private var isLoading: Bool = false
    @State private var page: Int = 1
    private let pageSize: Int = 20
    
    var body: some View {
        if searchEntry == nil {
            
            NavigationSplitView{
                List(docs, id: \.id, selection: $selectedId) { document in
                    VStack{
                        NavigationLink {
                            if let docId = selectedId {
                                if let selected = docMaps[docId] {
                                    DocumentDetailView(entryId: selected.oid)
                                        .id("\(selected.oid)/doc")
                                }
                            }
                        } label: {
                            DocumentItemView(doc: document, unreadPage: true)
                                .id("\(document.oid)/docitem")
                        }
                        
                        if self.isLoading && self.docs.isLastItem(document) {
                            Divider()
                            Text("Loading ...")
                                .padding(.vertical)
                        }
                    }
                    .onAppear{
                        Task.detached{
                            listItemAppears(document)
                        }
                    }
                }
                .contextMenu{
                    if let select = docMaps[selectedId ?? 0] { DocumentButtonView(doc: select).id(select.id) }
                }
                .toolbar {
                    ToolbarItem(placement: .primaryAction) {
                        Picker("select", selection: $parentSelected) {
                            Text("Select").tag(nil as String?)
                            ForEach(parentNames, id: \.self) { option in
                                Text(option).tag(option as String?)
                            }
                        }
                        .pickerStyle(.menu)
                    }
                }
                .frame(minWidth: 300, idealWidth: 300)
                .onAppear{
                    Task.detached{
                        loadNextPageDocuments()
                        let groups = documentService.listDocumentGroups(parentId: nil, filter: filter)
                        for group in groups {
                            parentNames.append(group.name)
                            parentMaps[group.name] = group
                        }
                    }
                }
                .onChange(of: selectedId) {
                    Task.detached{
                        if let selectDocId = selectedId {
                            documentService.updateDocument(docUpdate: DocumentUpdate(docId: selectDocId, unread: false))
                            let selected = docMaps[selectedId!]
                            if let index = docs.firstIndex(of: selected!) {
                                self.docs[index].unread = false
                            }
                        }
                    }
                }
                .onChange(of: parentSelected) {
                    Task.detached {
                        self.page = 1
                        self.docs = []
                        self.docMaps = [:]
                        loadNextPageDocuments()
                    }
                }
                .listStyle(.inset)
            } detail: {
            }
        } else {
            DocumentDetailView(entryId: searchEntry!)
                .id("\(String(describing: searchEntry))/doc")
                .layoutPriority(1)
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
        var parent: EntryInfoModel?
        if let parentNameSelect = parentSelected {
            parent = parentMaps[parentNameSelect]
        }
        var f = self.filter
        f.parentId = parent?.id
        let moreDocs = documentService.listDocuments(
            filter: f,
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
