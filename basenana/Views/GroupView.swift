//
//  GroupView.swift
//  basenana
//
//  Created by Hypo on 2024/3/2.
//

import SwiftUI

struct GroupView: View{
    var group: GroupViewModel
    var entries: [EntryViewModel]
    var selectedEntry: EntryViewModel?
    
    init(group: GroupViewModel) {
        self.group = group
        self.entries = group.listChildren()
    }
    
    var body: some View {
        Table(entries) {
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
//        Text("display files in group view \(group.name)")
    }
}


#Preview {
    GroupView(group: GroupViewModel(group: buildGroup(id: Int64(10))))
}
