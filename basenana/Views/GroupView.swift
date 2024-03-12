//
//  GroupView.swift
//  basenana
//
//  Created by Hypo on 2024/3/2.
//

import SwiftUI
import SwiftData

struct GroupView: View{
    @Environment(\.modelContext) private var context
    var groupEntry: EntryModel
    @Query(filter: #Predicate<EntryModel>{$0.parent == rootEntryID}, sort: \EntryModel.name) private var groupChileren: [EntryModel]

    var body: some View {
        Table(groupChileren) {
            TableColumn("Name") {
                Text($0.name)
            }
            TableColumn("Kind") {
                Text($0.kind)
            }.width(120)
            TableColumn("Size") {
                Text("\($0.size)")
            }.width(120)
            TableColumn("Date Modified") {
                Text("\($0.modifiedAt, format: Date.FormatStyle(date: .numeric, time: .standard))")
            }.width(120)
        }
    }
}

