//
//  GroupView.swift
//  basenana
//
//  Created by Hypo on 2024/3/2.
//

import SwiftUI
import SwiftData

struct GroupView: View{
    var groupID: Int64
    @State private var groupChileren: [EntryInfoModel] = []
    @State private var docMaps: [Int64:DocumentInfoModel] = [:]
    @State private var selection: Set<EntryInfoModel.ID> = []
    @State var order: [KeyPathComparator<EntryInfoModel>] = [.init(\.name, order: .forward)]
    
    @Binding var searchEntry: Int64?
    
    @State private var showAlert = false
    @State private var entryToDelete: EntryInfoModel? = nil
    
    var body: some View {
        GeometryReader { geometry in
            VStack{
                VSplitView(){
                    if searchEntry == nil {
                        Table(of: EntryInfoModel.self, selection: $selection, sortOrder: $order) {
                            TableColumn("Name", value: \.name) { entry in
                                if entry.isGroup {
                                    HStack {
                                        Image(systemName: "folder")
                                            .frame(width: 12, alignment: .center)
                                        Text("\(entry.name)")
                                    }
                                } else {
                                    HStack {
                                        Image(systemName: "doc.text")
                                            .frame(width: 12, alignment: .center)
                                        Text("\(entry.name)")
                                    }
                                }
                            }
                            TableColumn("Kind", value: \.kind)
                            TableColumn("Size", value: \.size) {
                                Text("\($0.size)")
                            }
                            TableColumn("Date Modified", value: \.modifiedAt) {
                                Text("\($0.modifiedAt, format: Date.FormatStyle(date: .numeric, time: .standard))")
                            }
                        } rows: {
                            ForEach(groupChileren, id: \.id) { child in
                                let childDoc = docMaps[child.id]
                                TableRow(child)
                                    .contextMenu {
                                        if let doc = childDoc {
                                            DocumentButtonView(doc: doc).id(doc.id)
                                            Divider()
                                        }
                                        
                                        Button(action: {
                                            showAlert = true
                                            entryToDelete = child
                                        }) {
                                            Text("Delete")
                                            Image(systemName: "trash")
                                        }
                                    }
                                    .draggable(IDHelper(kind: child.isGroup ? "group" : "entry", id: child.id).Encode())
                                    .dropDestination(for: String.self){ entryInfos in
                                        if !child.isGroup {
                                            return
                                        }
                                        groupService.moveEntriesToGroup(entries: parseIDInfo(entryInfos: entryInfos), groupID: child.id)
                                    }
                            }
                        }
                        .dropDestination(for: String.self){ entryInfos, _ in
                            groupService.moveEntriesToGroup(entries: parseIDInfo(entryInfos: entryInfos), groupID: groupID)
                            return false
                        }
                        .onAppear{
                            Task.detached{
                                groupChileren = entryService.listChildren(parentEntryID: groupID, order: EntryOrder(order: EnOrder.modifiedAt, desc: true))
                                let docs = documentService.listDocuments(filter: Docfilter(parentId: groupID))
                                for doc in docs {
                                    docMaps[doc.oid] = doc
                                }
                            }
                        }
                        .onChange(of: order){
                            withAnimation {
                                groupChileren.sort(using: order)
                            }
                        }
                        .frame(minHeight: 200, maxHeight: .infinity)
                        .alert(isPresented: $showAlert) {
                            Alert(
                                title: Text("Confirm Delete"),
                                message: Text("Are you sure delete \"\(entryToDelete?.name ?? "")\" ?"),
                                primaryButton: .destructive(Text("Delete")) {
                                    if let entryId = entryToDelete?.id {
                                        Task.detached { entryService.deleteEntry(entryId: entryId) }
                                    }
                                },
                                secondaryButton: .cancel()
                            )
                        }
                        
                        
                        if selection.count == 1 {
                            if let unwrappedID = selection.first {
                                DocumentDetailView(entryId: unwrappedID)
                                    .id("\(unwrappedID)/doc")
                                    .frame(minHeight: 300, idealHeight: geometry.size.height/2)
                                    .layoutPriority(1)
                            }
                        }
                    } else {
                        DocumentDetailView(entryId: searchEntry!)
                            .id("\(String(describing: searchEntry))/doc")
                    }
                }
                .layoutPriority(1)
            }
        }
    }
}

