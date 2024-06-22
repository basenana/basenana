//
//  GroupTableView.swift
//  basenana
//
//  Created by Hypo on 2024/6/22.
//

import SwiftUI
import Foundation


struct GroupTableView: View {
    @Binding var group: GroupViewModel
    @State var order: [KeyPathComparator<EntryInfoModel>] = [.init(\.name, order: .forward)]
    
    var body: some View {
        Table(of: EntryInfoModel.self, selection: $group.selection, sortOrder: $order) {
            TableColumn("Name") { entry in
                HStack {
                    Image(systemName: entry.isGroup ? "folder" : "doc.text")
                        .frame(width: 12, alignment: .center)
                    Text("\(entry.name)")
                }
            }
            TableColumn("Kind", value: \.kind)
            TableColumn("Size") {
                Text("\($0.size)")
            }
            TableColumn("Date Modified") {
                Text("\($0.modifiedAt, format: Date.FormatStyle(date: .numeric, time: .standard))")
            }
        } rows: {
            ForEach(group.children, id: \.id) { child in
                TableRow(child)
            }
        }
        .onChange(of: order){
            withAnimation {
                group.children.sort(using: order)
            }
        }
    }
}
