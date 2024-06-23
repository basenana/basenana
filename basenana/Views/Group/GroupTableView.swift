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
    @Environment(\.goGroupListView) var goGroupListView
    @Environment(Store.self) private var store: Store
    
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
                    .draggable(IDHelper(kind: "entry", id: child.id).Encode())
            }
        }
        .contextMenu{
            Button("goto", action: {
                if let selected = group.selection.first {
                    for en in group.children {
                        if en.id != selected {
                            continue
                        }
                        if en.isGroup {
                            goGroupListView(en.toGroup()!)
                        }
                    }
                }
                log.info("\(group.selection)")
            })
        }
        .onChange(of: order){
            withAnimation {
                group.children.sort(using: order)
            }
        }
    }
}
