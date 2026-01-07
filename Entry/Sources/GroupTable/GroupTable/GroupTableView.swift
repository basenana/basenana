//
//  GroupTableView.swift
//  Entry
//
//  Created by Hypo on 2024/10/14.
//

import os
import SwiftUI
import Foundation
import AppState
import Entities


public struct GroupTableView: View {
    @State private var groupID: Int64
    @State private var groupName: String? = nil
    
    @State private var viewModel: GroupTableViewModel
    
    private static let logger = Logger(
            subsystem: Bundle.main.bundleIdentifier!,
            category: String(describing: GroupTableView.self)
        )
    
    public init(groupID: Int64, viewModel: GroupTableViewModel) {
        self.groupID = groupID
        self.groupName = ""
        self.viewModel = viewModel
    }
    
    public var body: some View {
        VStack {
            GroupTableWithSheetView(groupID: groupID, viewModel: viewModel)
        }
        .onReceive(NotificationCenter.default.publisher(for: .reopenGroup)) { [self] notification in
            if let parents = notification.object as? [Int64] {
                var needReopen = false
                for p in parents {
                    if p != groupID {
                        continue
                    }
                    needReopen = true
                    break
                }
                
                if needReopen {
                    Task {
                        // reopen
                        await viewModel.openGroup(groupID: groupID)
                    }
                }
            }
        }
        .task {
            Self.logger.notice("open group \(groupID)")
            await viewModel.openGroup(groupID: groupID)
            
            if let opg = viewModel.group {
                if opg.name == ".inbox" {
                    groupName = "Inbox"
                } else {
                    groupName = opg.name
                }
            }
        }
        .navigationTitle(groupName ?? "")
        .toolbar{
            ToolbarItemGroup(placement: .primaryAction){
                FileToolBarView(viewModel: viewModel)
            }
        }
    }
}

private struct GroupTableWithSheetView: View {
    @State private var groupID: Int64
    @State private var viewModel: GroupTableViewModel
    
    @State private var showCreateGroup: Bool = false
    @State private var createGroupInParent: Int64 = -1
    @State private var createGroupType: GroupType = .standard
    
    @State private var showDeleteConfirm: Bool = false
    @State private var needDeletedEnties: [Int64] = []
    
    @State private var showRenameEntry: Bool = false
    @State private var renameEntry: Int64 = -1
    
    init(groupID: Int64, viewModel: GroupTableViewModel) {
        self.groupID = groupID
        self.viewModel = viewModel
    }
    
    public var body: some View {
        GroupTableWithDropView(groupID: groupID, viewModel: viewModel)
            .sheet(isPresented: $showCreateGroup){
                GroupCreateView(
                    parent: createGroupInParent,
                    groupType: createGroupType,
                    viewModel: CreateDeleteViewModel(store: viewModel.store, entryUsecase: viewModel.entryUsecase),
                    showCreateGroup: $showCreateGroup)
            }
            .onReceive(NotificationCenter.default.publisher(for: .createGroup)) { [self] notification in
                if let req = notification.object as? NewGroupRequest {
                    self.createGroupInParent = req.parent
                    self.createGroupType = req.groupType
                    self.showCreateGroup.toggle()
                }
            }
            .onChange(of: createGroupInParent){}
            .onChange(of: createGroupType){}
        
            .sheet(isPresented: $showRenameEntry){
                EntryRenameView(
                    entry: renameEntry,
                    viewModel: EntryDetailViewModel(
                        store: viewModel.store,entryUsecase: viewModel.entryUsecase),
                    showRenameView: $showRenameEntry)
            }
            .onReceive(NotificationCenter.default.publisher(for: .renameEntry)) { [self] notification in
                if let gid = notification.object as? Int64 {
                    self.renameEntry = gid
                    self.showRenameEntry.toggle()
                }
            }
            .onChange(of: renameEntry){}
        
            .sheet(isPresented: $showDeleteConfirm){
                DeleteEntriesView(
                    entryIDs: needDeletedEnties,
                    viewModel: CreateDeleteViewModel(store: viewModel.store, entryUsecase: viewModel.entryUsecase),
                    showDeleteView: $showDeleteConfirm)
            }
            .onReceive(NotificationCenter.default.publisher(for: .deleteEntry)) { [self] notification in
                if let entries = notification.object as? [Int64] {
                    self.needDeletedEnties = entries
                    self.showDeleteConfirm.toggle()
                }
            }
            .onChange(of: needDeletedEnties){}
    }
}


private struct GroupTableWithDropView: View {
    @State private var groupID: Int64
    @State private var viewModel: GroupTableViewModel
    
    init(groupID: Int64, viewModel: GroupTableViewModel) {
        self.groupID = groupID
        self.viewModel = viewModel
    }
    
    public var body: some View {
        GroupTableWithMenuView(groupID: groupID, viewModel: viewModel)
            .dropDestination(for: URL.self){ urls, _  in
                Task {
                    await viewModel.moveEntriesToGroup(entryURLs: urls, newParent: groupID)
                }
                return true
            }
    }
}

private struct GroupTableWithMenuView: View {
    @State private var groupID: Int64
    @State private var viewModel: GroupTableViewModel
    
    init(groupID: Int64, viewModel: GroupTableViewModel) {
        self.groupID = groupID
        self.viewModel = viewModel
    }
    
    public var body: some View {
        GroupTableContentView(groupID: groupID, viewModel: viewModel)
            .contextMenu{
                EntryMenuView(viewModel: viewModel)
            }
            .contextMenu(forSelectionType: EntryRow.ID.self) { items in
                EntryMenuView(viewModel: viewModel)
            } primaryAction: { items in
                if  items.count == 1 {
                    if let grp = viewModel.children.filter({$0.id == items.first! && $0.isGroup}).first{
                        gotoDestination(.groupList(group: grp.id))
                    }
                }
            }
    }
}

private struct GroupTableContentView: View {
    @State private var groupID: Int64
    @State private var viewModel: GroupTableViewModel
    @State private var order: [KeyPathComparator<EntryRow>] = [.init(\.name, order: .forward)]
    
    init(groupID: Int64, viewModel: GroupTableViewModel) {
        self.groupID = groupID
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
                    Text($0.readableSize)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                }
            }
            TableColumn("Date Modified", value: \.modifiedAt) {
                Text("\($0.modifiedAt, format: Date.FormatStyle(date: .numeric, time: .standard))")
            }
        } rows: {
            ForEach(viewModel.children, id: \.id) { child in
                if child.isGroup{
                    
                    TableRow(child)
                        .draggable(EntryUrl(entryID: child.id))
                        .dropDestination(for: URL.self){ urls in
                            Task {
                                let _ = await viewModel.moveEntriesToGroup(entryURLs: urls, newParent: child.id)
                            }
                        }
                } else {
                    
                    TableRow(child)
                        .draggable(EntryUrl(entryID: child.id))
                }
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
