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
    @State private var groupChileren: [EntryModel] = []
    @State private var selection: Set<EntryModel.ID> = []
    @State private var selectedDoc: DocumentModel? = nil
    @State var order: [KeyPathComparator<EntryModel>] = [.init(\.name, order: .forward)]
    
    var body: some View {
        GeometryReader { geometry in
            VStack{
                
                VSplitView(){
                    Table(of: EntryModel.self, selection: $selection, sortOrder: $order) {
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
                                .draggable(IDHelper(kind: child.isGroup ? "group" : "entry", id: child.id!).Encode())
                                .dropDestination(for: String.self){ entryInfos in
                                    if !child.isGroup {
                                        return
                                    }
                                    groupService.moveEntriesToGroup(entries: parseIDInfo(entryInfos: entryInfos), groupID: child.id!)
                                }
                        }
                    }
                    .dropDestination(for: String.self){ entryInfos, _ in
                        groupService.moveEntriesToGroup(entries: parseIDInfo(entryInfos: entryInfos), groupID: groupID)
                        return false
                    }
                    .onAppear{
                        groupChileren = entryService.listChildren(parentEntryID: groupID, orderName: EntryOrder.modifiedAt, desc: true)
                    }
                    .onChange(of: GroupRoot.updateAt){
                        groupChileren = entryService.listChildren(parentEntryID: groupID, orderName: EntryOrder.modifiedAt, desc: true)
                        log.info("relist group \(groupID) children")
                    }
                    .onChange(of: order){
                        withAnimation {
                            groupChileren.sort(using: order)
                        }
                    }
                    .frame(minHeight: 200, maxHeight: .infinity)
                    
                    if selection.count == 1 {
                        if let unwrappedID = selection.first {
                            let entryId: Int64 = unwrappedID ?? 0
                            DocumentDetailView(doc: documentService.getDocument(entryId: entryId))
                                .frame(minHeight: 300, idealHeight: geometry.size.height/2)
                                .layoutPriority(1)
                        }
                    }
                }
                .layoutPriority(1)
            }
        }
    }
}

