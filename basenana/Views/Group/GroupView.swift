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
    @State private var selection: Set<EntryInfoModel.ID> = []
    @State private var selectedDoc: DocumentInfoModel? = nil
    @State var order: [KeyPathComparator<EntryInfoModel>] = [.init(\.name, order: .forward)]
    
    @Binding var searchEntry: Int64?
    
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
                            ForEach(groupChileren) { child in
                                TableRow(child)
                                    .contextMenu {
                                        Button("Edit") {
                                            // TODO open editor in inspector
                                        }
                                        Button("See Details") {
                                            // TODO open detai view
                                        }
                                        Divider()
                                        Button("Delete", role: .destructive) {
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
                            }
                        }
                        .onChange(of: order){
                            withAnimation {
                                groupChileren.sort(using: order)
                            }
                        }
                        .frame(minHeight: 200, maxHeight: .infinity)
                        
                        if selection.count == 1 {
                            if let unwrappedID = selection.first {
                                DocumentDetailView(entryId: unwrappedID)
                                    .frame(minHeight: 300, idealHeight: geometry.size.height/2)
                                    .layoutPriority(1)
                            }
                        }
                    } else {
                        DocumentDetailView(entryId: searchEntry!)
                    }
                }
                .layoutPriority(1)
            }
        }
    }
}

