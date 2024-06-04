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
    @State private var parentMaps: [String:GroupViewModel] = [:]
    
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
                                .id("\(selected.oid)/docitem")
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
                    if let select = docMaps[selectedId ?? 0] {
                        Button {
                            withAnimation(.easeInOut) {
                                documentService.updateDocument(docUpdate: DocumentUpdate(docId: selectedId!, unread: !select.unread))
                            }
                        } label: {
                            if select.unread {
                                Image(systemName: "circle").resizable().frame(width: 1, height: 1)
                                Text("Read")
                            }else{
                                Image(systemName: "circle.fill").resizable().frame(width: 1, height: 1)
                                Text("Unread")
                            }
                        }
                        Button {
                            withAnimation(.easeInOut) {
                                documentService.updateDocument(docUpdate: DocumentUpdate(docId: selectedId!, marked: !select.marked))
                            }
                        } label: {
                            if select.marked {
                                Image(systemName: "star").resizable().frame(width: 1, height: 1)
                                Text("Unmark")
                            }else{
                                Image(systemName: "star.fill").resizable().frame(width: 1, height: 1)
                                Text("Mark")
                            }
                        }
                    }
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
                        let groups = getLeafs(groupPrefix: "", group: GroupRoot)
                        for group in groups {
                            var groupName = group.groupName
                            if group.prefix != nil && group.prefix != "" {
                                groupName = "\(group.prefix ?? "")/\(group.groupName)"
                            }
                            parentNames.append(groupName)
                            parentMaps[groupName] = group
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
        var parent: GroupViewModel?
        if let parentNameSelect = parentSelected {
            parent = parentMaps[parentNameSelect]
        }
        var f = self.filter
        f.parentId = parent?.groupID
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
