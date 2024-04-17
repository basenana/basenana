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
    
    var body: some View {
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
            }
        }
        .toolbar {
            if groupID != inboxEntryID{
                ToolbarItemGroup(placement: .secondaryAction) {
                    Button(action: {
                    }, label: {
                        Image(systemName: "ellipsis.message")
                    })
                }
            }
        }
        .onAppear{
            groupChileren = entryService.listChildren(parentEntryID: groupID)
        }
    }
}

