//
//  GroupTableView.swift
//  Entry
//
//  Created by Hypo on 2024/10/14.
//

import SwiftUI
import Foundation
import AppState
import Entities
import MenuView


@available(macOS 14.0, *)
public struct GroupTableView: View {
    
    @State private var viewModel: GroupTableViewModel
    @State private var order: [KeyPathComparator<EntryRow>] = [.init(\.name, order: .forward)]
    
    public init(viewModel: GroupTableViewModel) {
        self.viewModel = viewModel
    }
    
    public var body: some View {
        Table(of: EntryRow.self, selection: $viewModel.selection, sortOrder: $order) {
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
            ForEach(viewModel.children, id: \.id) { child in
                TableRow(child)
                    .draggable(IDHelper(kind: "entry", id: child.id).Encode())
            }
        }
        .task {
            viewModel.loadChildren()
        }
        .contextMenu{
            if viewModel.selection.count == 1 {
                let selectedID = viewModel.selection.first!
                let selected = viewModel.children.filter({ $0.id == selectedID }).first
                MenuView(viewModel: MenuViewModel(store: viewModel.store, entry: selected?.info))
            }else {
                MenuView(viewModel: MenuViewModel(store: viewModel.store))
            }
        }
        .onChange(of: order){
            withAnimation {
                viewModel.children.sort(using: order)
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


#if DEBUG

import DomainTestHelpers

#Preview {
    if #available(macOS 14.0, *) {
        GroupTableView(viewModel: GroupTableViewModel(id: 1010, store: StateStore.empty, usercase: MockEntryTreeUseCase()))
    }
}

#endif
