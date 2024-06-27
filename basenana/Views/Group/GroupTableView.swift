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
            TableColumn("Name", value: \.name) { entry in
                HStack {
                    Image(systemName: entry.isGroup ? "folder" : "doc.text")
                        .frame(width: 12, alignment: .center)
                    Text("\(entry.name)")
                }
            }
            TableColumn("Kind", value: \.kind)
            TableColumn("Size", value: \.size) {
                if $0.isGroup {
                    Text("--")
                        .frame(maxWidth: .infinity, alignment: .trailing)
                } else {
                    Text(bytesToHumanReadableString(bytes: $0.size))
                        .frame(maxWidth: .infinity, alignment: .trailing)
                }
            }
            TableColumn("Date Modified", value: \.modifiedAt) {
                Text("\($0.modifiedAt, format: Date.FormatStyle(date: .numeric, time: .standard))")
            }
        } rows: {
            ForEach(group.children.filter({ store.state.search.filterEntryName($0) }), id: \.id) { child in
                TableRow(child)
                    .draggable(IDHelper(kind: "entry", id: child.id).Encode())
            }
        }
        .contextMenu{
            if group.selection.count == 1 {
                let selectedID = group.selection.first!
                GroupMenuView(entry: group.children.filter({ $0.id == selectedID }).first, group: nil)
            }else {
                GroupMenuView(entry: nil, group: nil)
            }
        }
        .onChange(of: order){
            withAnimation {
                group.children.sort(using: order)
            }
        }
    }
}


func bytesToHumanReadableString(bytes: Int64) -> String {
    let kilobyte: Int64 = 1024
    let megabyte = kilobyte * 1024
    let gigabyte = megabyte * 1024
    let terabyte = gigabyte * 1024
    
    if bytes < kilobyte {
        return "\(bytes) B"
    } else if bytes < megabyte {
        return String(format: "%.2f KB", Double(bytes) / Double(kilobyte))
    } else if bytes < gigabyte {
        return String(format: "%.2f MB", Double(bytes) / Double(megabyte))
    } else if bytes < terabyte {
        return String(format: "%.2f GB", Double(bytes) / Double(gigabyte))
    } else {
        return String(format: "%.2f TB", Double(bytes) / Double(terabyte))
    }
}
