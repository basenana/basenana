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
    @Binding var refreshToggle: Bool
    @Binding var searchEntry: Int64?

    @State private var groupChileren: [EntryInfoModel] = []
    @State private var selection: Set<EntryInfoModel.ID> = []
    @State private var selectDoc: DocumentDetailModel? = nil
    @State var order: [KeyPathComparator<EntryInfoModel>] = [.init(\.name, order: .forward)]
    
    @State private var showAlert = false
    @State private var entriesToDelete: Set<EntryInfoModel.ID> = []
    
    @State var selectedMoved = false
    
    var body: some View {
        GeometryReader { geometry in
            VStack{
                VSplitView(){
                    if searchEntry == nil {
                        Table(of: EntryInfoModel.self, selection: $selection, sortOrder: $order) {
                            TableColumn("Name", value: \.name) { entry in
                                HStack {
                                    Image(systemName: entry.isGroup ? "folder" : "doc.text")
                                        .frame(width: 12, alignment: .center)
                                    Text("\(entry.name)")
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
                                TableRow(child)
                                    .contextMenu {
                                        if let doc = selectDoc, selection.count == 1 {
                                            DocumentButtonView(doc: documentService.docDetail2Info(doc: doc)).id(doc.id)
                                            Divider()
                                        }
                                        
                                        Button(action: {
                                            showAlert = true
                                            entriesToDelete = selection
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
                                        refreshToggle.toggle()
                                    }
                            }
                        }
                        .dropDestination(for: String.self){ entryInfos, _ in
                            groupService.moveEntriesToGroup(entries: parseIDInfo(entryInfos: entryInfos), groupID: groupID)
                            refreshToggle.toggle()
                            return false
                        }
                        .onAppear{
                            Task.detached{
                                groupChileren = entryService.listChildren(parentEntryID: groupID, order: EntryOrder(order: EnOrder.modifiedAt, desc: true))
                            }
                        }
                        .onChange(of: order){
                            withAnimation {
                                groupChileren.sort(using: order)
                            }
                        }
                        .onChange(of: selection) {
                            if selection.count == 1, let unwrappedID = selection.first {
                                selectDoc = documentService.getDocument(entryId: unwrappedID)
                            }
                        }
                        .onChange(of: refreshToggle) {
                            Task.detached{
                                groupChileren = entryService.listChildren(parentEntryID: groupID, order: EntryOrder(order: EnOrder.modifiedAt, desc: true))
                            }
                        }
                        .frame(minHeight: 200, maxHeight: .infinity)
                        .alert(isPresented: $showAlert) {
                            Alert(
                                title: Text("Confirm Delete"),
                                message: Text("Are you sure delete these files or folders?"),
                                primaryButton: .destructive(Text("Delete")) {
                                    Task.detached { entryService.deleteEntries(entryIds: Array(entriesToDelete)) }
                                },
                                secondaryButton: .cancel()
                            )
                        }
                        
                        
                        if let doc = selectDoc {
                            DocumentDetailView(entryId: nil, doc: selectDoc)
                                .id("\(doc.oid)/doc")
                                .frame(minHeight: 300, idealHeight: geometry.size.height/2)
                                .layoutPriority(1)
                        }
                    }
                    
                    if let searchEn = searchEntry {
                        DocumentDetailView(entryId: searchEn, doc: nil)
                            .id("\(String(describing: searchEntry))/doc")
                    }
                }
                .layoutPriority(1)
            }
        }
    }
}
