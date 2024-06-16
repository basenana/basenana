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
    
    @State private var groupChileren: [EntryInfoModel] = []
    @State private var selection: Set<EntryInfoModel.ID> = []
    @State private var selectDoc: DocumentDetailModel? = nil
    @State var order: [KeyPathComparator<EntryInfoModel>] = [.init(\.name, order: .forward)]
    @State private var showAlert = false
    @State private var entriesToDelete: Set<EntryInfoModel.ID> = []
    @State var selectedMoved = false
    @State private var deleteProgress = 0.0
    @State private var showProgressSheet = false
    
    @Environment(AlertStore.self) var alert
    
    var body: some View {
        GeometryReader { geometry in
            VStack{
                VSplitView(){
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
                                        DocumentButtonView(doc: service.docDetail2Info(doc: doc)).id(doc.id)
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
                                    do {
                                        try service.moveEntriesToGroup(entries: parseIDInfo(entryInfos: entryInfos), groupID: child.id)
                                        refreshToggle.toggle()
                                    } catch {
                                        alert.trigger(message: "\(error)")
                                    }
                                }
                    }
                }
                .onAppear{
                    Task.detached{
                        do {
                            groupChileren = try service.listChildren(parentEntryID: groupID, order: EntryOrder(order: EnOrder.modifiedAt, desc: true))
                        } catch {
                            alert.trigger(message: "\(error)")
                        }
                    }
                }
                .onChange(of: order){
                    withAnimation {
                        groupChileren.sort(using: order)
                    }
                }
                .onChange(of: selection) {
                    if selection.count == 1, let unwrappedID = selection.first {
                        do {
                            selectDoc = try service.getDocument(entryId: unwrappedID)
                        } catch {
                            alert.trigger(message: "\(error)")
                        }
                    }
                }
                .onChange(of: refreshToggle) {
                    Task.detached{
                        do {
                            groupChileren = try service.listChildren(parentEntryID: groupID, order: EntryOrder(order: EnOrder.modifiedAt, desc: true))
                        } catch {
                            alert.trigger(message: "\(error)")
                        }
                    }
                }
                .frame(minHeight: 200, maxHeight: .infinity)
                .sheet(isPresented: $showProgressSheet) {
                    VStack {
                        Text("Deleting...")
                        ProgressView(value: deleteProgress)
                    }
                    .padding()
                }
                .alert(isPresented: $showAlert) {
                    Alert(
                        title: Text("Confirm Delete"),
                        message: Text("Are you sure delete these files or folders?"),
                        primaryButton: .destructive(Text("Delete")) {
                            Task.detached {
                                do {
                                    var leafs: [Int64] = []
                                    for en in entriesToDelete {
                                        let children = try service.listChildLeafs(parentID: en)
                                        leafs += children
                                    }
                                    
                                    let all = leafs.count
                                    showProgressSheet = true
                                    for child in leafs {
                                        try await service.deleteEntry(entryId: child)
                                        deleteProgress += 1.0/Double(all)
                                    }
                                    try await Task.sleep(nanoseconds: 500_000_000)
                                    showProgressSheet = false
                                    refreshToggle.toggle()
                                } catch {
                                    alert.trigger(message: "\(error)")
                                }
                            }
                        },
                        secondaryButton: .cancel()
                    )
                }
                
                if let doc = selectDoc {
                    DocumentDetailView(entryId: selectDoc!.oid)
                        .id("\(doc.oid)/doc")
                        .frame(minHeight: 300, idealHeight: geometry.size.height/2)
                        .layoutPriority(1)
                }
            }
        }
    }
}
}
