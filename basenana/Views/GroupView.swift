//
//  GroupView.swift
//  basenana
//
//  Created by Hypo on 2024/3/2.
//

import SwiftUI

struct GroupView: View{
    @State private var groupEntry: EntryViewModel
    
    init(groupEntry: EntryViewModel) {
        self.groupEntry = groupEntry
    }
    
    var body: some View {
        Table(self.groupEntry.children) {
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

