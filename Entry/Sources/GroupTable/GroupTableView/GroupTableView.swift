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


@available(macOS 14.0, *)
public struct GroupTableView: View {
    @State private var groupID: Int64
    @State private var groupName: String? = nil
    @State private var groupTree = GroupTree.shared
    
    @State private var group: EntryDetail? = nil
    @State private var children: [EntryRow] = []
    
    @State private var viewModel: TreeViewModel
    @State var selection: Set<EntryRow.ID> = []
    @State var selectedDocument: DocumentDetail? = nil
    @State private var order: [KeyPathComparator<EntryRow>] = [.init(\.name, order: .forward)]
    
    public init(groupID: Int64, viewModel: TreeViewModel) {
        self.groupID = groupID
        self.groupName = ""
        self.viewModel = viewModel
    }

    public var body: some View {
        VStack {
            Table(of: EntryRow.self, selection: $selection, sortOrder: $order) {
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
                        Text($0.readableSize)
                            .frame(maxWidth: .infinity, alignment: .trailing)
                    }
                }
                TableColumn("Date Modified", value: \.modifiedAt) {
                    Text("\($0.modifiedAt, format: Date.FormatStyle(date: .numeric, time: .standard))")
                }
            } rows: {
                ForEach(viewModel.opendGroupChildren, id: \.id) { child in
                    if child.isGroup{
                        
                        TableRow(child)
                            .draggable(EntryUrl(entryID: child.id))
                            .dropDestination(for: URL.self){ urls in
                                Task {
                                    let _ = await viewModel.moveEntriesToGroup(entryURLs: urls, newParent: child.id)
                                }
                            }
                            .contextMenu{
                                EntryMenuView(target: child.info, viewModel: viewModel)
                            }
                    } else {
                        
                        TableRow(child)
                            .draggable(EntryUrl(entryID: child.id))
                            .contextMenu{
                                EntryMenuView(target: child.info, viewModel: viewModel)
                            }
                    }
                }
            }
            .onChange(of: order){
                withAnimation {
                    viewModel.opendGroupChildren.sort(using: order)
                }
            }
            .task {
                await viewModel.openGroup(groupID: groupID)
                
                if let opg = viewModel.opendGroup {
                    if opg.name == ".inbox" {
                        groupName = "Inbox"
                    } else {
                        groupName = opg.name
                    }
                }
            }
            .navigationTitle(groupName ?? "")
            .contextMenu{
                if let grp = viewModel.opendGroup {
                    EntryMenuView(target: grp.toInfo()!, viewModel: viewModel)
                }
            }
        }
        .dropDestination(for: URL.self){ urls, _  in
            Task {
                await viewModel.moveEntriesToGroup(entryURLs: urls, newParent: groupID)
            }
            return true
        }
    }
    
    func getSelectedEntry() -> EntryRow?{
        if selection.count == 1 {
            let selectedID = selection.first!
            return viewModel.opendGroupChildren.filter({ $0.id == selectedID }).first
        }else {
            return nil
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
        GroupTableView(groupID: 1010, viewModel: TreeViewModel(store: StateStore.empty, entryUsecase: MockEntryUseCase()))
    }
}

#endif
