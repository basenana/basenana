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
    
    var body: some View {
        VStack{
            
            VSplitView(){
                Table(of: EntryModel.self, selection: $selection) {
                    TableColumn("Name", value: \.name)
                    TableColumn("Kind", value: \.kind)
                    TableColumn("Size"){
                        Text("\($0.size)")
                    }
                    TableColumn("Date Modified") {
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
                    groupChileren = entryService.listChildren(parentEntryID: groupID)
                }
                .onChange(of: GroupRoot.updateAt){
                    groupChileren = entryService.listChildren(parentEntryID: groupID)
                    log.info("relist group \(groupID) children")
                }
                .frame(minHeight: 200, maxHeight: .infinity)
                
                if selection.count == 1 {
                    if let unwrappedID = selection.first {
                        let entryId: Int64 = unwrappedID ?? 0
                        DocumentDetailView(doc: documentService.getDocument(entryId: entryId))
                            .frame(minHeight: 500, idealHeight: .infinity/2, maxHeight: .infinity)
                            .layoutPriority(1)
                    }
                }
            }
            .layoutPriority(1)
        }
        
    }
}

