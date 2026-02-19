//
//  GroupTableView.swift
//  Entry
//
//  Created by Hypo on 2024/10/14.
//

import os
import SwiftUI
import Foundation
import Domain
import Data


public struct GroupTableView: View {
    @State private var groupUri: String
    @State private var groupName: String? = nil

    @State private var viewModel: GroupTableViewModel

    private static let logger = Logger(
            subsystem: Bundle.main.bundleIdentifier!,
            category: String(describing: GroupTableView.self)
        )

    public init(groupUri: String, viewModel: GroupTableViewModel) {
        self.groupUri = groupUri
        self.groupName = ""
        self.viewModel = viewModel
    }

    public var body: some View {
        VStack(spacing: 0) {
            GroupTableWithSheetView(groupUri: groupUri, viewModel: viewModel)
        }
        .onReceive(NotificationCenter.default.publisher(for: .reopenGroup)) { [self] notification in
            if let uris = notification.object as? [String] {
                var needReopen = false

                if uris.count == 2 {
                    // Move notification: [oldUri, newUri]
                    let currentUri = groupUri
                    let movedFrom = uris[0]
                    let movedTo = uris[1]
                    // Check if oldUri or newUri has the current groupUri as prefix
                    if movedFrom.hasPrefix(currentUri) || movedTo.hasPrefix(currentUri) {
                        needReopen = true
                    }
                } else {
                    // Simple reopen notification
                    for u in uris {
                        if u != groupUri {
                            continue
                        }
                        needReopen = true
                        break
                    }
                }

                if needReopen {
                    Task {
                        await viewModel.openGroup(uri: groupUri)
                    }
                }
            }
        }
        .onAppear {
            Self.logger.notice("onAppear group \(groupUri)")
            Task {
                await viewModel.openGroup(uri: groupUri)
            }

            if let opg = viewModel.group {
                if opg.name == ".inbox" {
                    groupName = "Inbox"
                } else {
                    groupName = opg.name
                }
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .childrenChanged)) { notification in
            if let change = notification.object as? ChildrenChange {
                // Only refresh if the change is for the current group's children
                if change.parentUri == viewModel.currentGroupUri || change.parentUri.isEmpty {
                    Task {
                        await viewModel.refreshChildren()
                    }
                }
            }
        }
        .navigationTitle(groupName ?? "")
        .toolbar{
            ToolbarItemGroup(placement: .primaryAction){
                FileToolBarView(viewModel: viewModel)
            }

            ToolbarItemGroup(placement: .secondaryAction){
                Button {
                    viewModel.store.showDocumentView.toggle()
                } label: {
                    Image(systemName: "doc.text.image")
                        .foregroundStyle(viewModel.store.showDocumentView ? Color.accentColor : Color.primary)
                }
                .help("Toggle Document View")

                Button {
                    viewModel.store.showInspector.toggle()
                } label: {
                    Image(systemName: "info.square")
                        .foregroundStyle(viewModel.store.showInspector ? Color.accentColor : Color.primary)
                }
                .help("Toggle Inspector")
            }
        }
    }
}

private struct GroupTableWithSheetView: View {
    @State private var groupUri: String
    @State private var viewModel: GroupTableViewModel

    @State private var showCreateGroup: Bool = false
    @State private var createGroupInParentUri: String = ""
    @State private var createGroupType: GroupType = .standard

    @State private var showDeleteConfirm: Bool = false
    @State private var needDeletedEnties: [String] = []

    @State private var showRenameEntry: Bool = false
    @State private var renameEntryUri: String = ""

    init(groupUri: String, viewModel: GroupTableViewModel) {
        self.groupUri = groupUri
        self.viewModel = viewModel
    }

    public var body: some View {
        GroupTableWithDropView(groupUri: groupUri, viewModel: viewModel)
            .sheet(isPresented: $showCreateGroup){
                GroupCreateView(
                    parentUri: createGroupInParentUri,
                    groupType: createGroupType,
                    viewModel: CreateDeleteViewModel(store: viewModel.store, entryUsecase: viewModel.entryUsecase),
                    store: viewModel.store,
                    showCreateGroup: $showCreateGroup,
                    onCreated: viewModel.group?.uri == createGroupInParentUri ? { info in
                        viewModel.addChildren(infos: [info])
                    } : nil
                )
            }
            .onReceive(NotificationCenter.default.publisher(for: .createGroup)) { [self] notification in
                if let req = notification.object as? NewGroupRequest {
                    self.createGroupInParentUri = req.parentUri
                    self.createGroupType = req.groupType
                    self.showCreateGroup.toggle()
                }
            }
            .onChange(of: createGroupInParentUri){}
            .onChange(of: createGroupType){}

            .sheet(isPresented: $showRenameEntry){
                EntryRenameView(
                    entryUri: renameEntryUri,
                    viewModel: EntryDetailViewModel(
                        store: viewModel.store,entryUsecase: viewModel.entryUsecase),
                    showRenameView: $showRenameEntry,
                    onRenamed: { id, newName, newUri in
                        viewModel.updateChild(id: id, newName: newName, newUri: newUri)
                    }
                )
            }
            .onReceive(NotificationCenter.default.publisher(for: .renameEntry)) { [self] notification in
                if let uri = notification.object as? String {
                    self.renameEntryUri = uri
                    self.showRenameEntry.toggle()
                }
            }
            .onChange(of: renameEntryUri){}

            .sheet(isPresented: $showDeleteConfirm){
                DeleteEntriesView(
                    entryUris: needDeletedEnties,
                    viewModel: CreateDeleteViewModel(store: viewModel.store, entryUsecase: viewModel.entryUsecase),
                    showDeleteView: $showDeleteConfirm,
                    onDeleted: { ids in
                        viewModel.removeChildren(ids: ids)
                    }
                )
            }
            .onReceive(NotificationCenter.default.publisher(for: .deleteEntry)) { [self] notification in
                if let uris = notification.object as? [String] {
                    self.needDeletedEnties = uris
                    self.showDeleteConfirm.toggle()
                }
            }
            .onChange(of: needDeletedEnties){}
    }
}


private struct GroupTableWithDropView: View {
    @State private var groupUri: String
    @State private var viewModel: GroupTableViewModel

    init(groupUri: String, viewModel: GroupTableViewModel) {
        self.groupUri = groupUri
        self.viewModel = viewModel
    }

    public var body: some View {
        GroupTableWithMenuView(groupUri: groupUri, viewModel: viewModel)
            .dropDestination(for: URL.self){ urls, _  in
                Task {
                    await viewModel.moveChildrenToGroup(entryURLs: urls, newParentUri: groupUri)
                }
                return true
            }
    }
}

private struct GroupTableWithMenuView: View {
    @State private var groupUri: String
    @State private var viewModel: GroupTableViewModel

    init(groupUri: String, viewModel: GroupTableViewModel) {
        self.groupUri = groupUri
        self.viewModel = viewModel
    }

    public var body: some View {
        @Environment(\.openWindow) var openWindow

        return GroupTableContentView(groupUri: groupUri, viewModel: viewModel)
            .contextMenu{
                EntryMenuView(viewModel: viewModel)
            }
            .contextMenu(forSelectionType: EntryRow.ID.self) { items in
                EntryMenuView(viewModel: viewModel)
            } primaryAction: { items in
                if  items.count == 1,
                   let item = viewModel.children.first(where: { $0.id == items.first }) {
                    if item.isGroup {
                        gotoDestination(.groupList(groupUri: item.uri))
                    } else {
                        openWindow(value: "document:" + item.uri)
                    }
                }
            }
    }
}

private struct GroupTableContentView: View {
    @State private var groupUri: String
    @State private var viewModel: GroupTableViewModel
    @State private var order: [KeyPathComparator<EntryRow>] = [.init(\.name, order: .forward)]

    init(groupUri: String, viewModel: GroupTableViewModel) {
        self.groupUri = groupUri
        self.viewModel = viewModel
    }

    public var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                VStack(spacing: 0) {
                    tableContent

                    if viewModel.showDocumentView {
                        documentViewSection
                    }
                }

                if viewModel.showInspector {
                    inspectorSection
                }
            }

            loadMoreTrigger
        }
        .onChange(of: viewModel.selection) { _, _ in
            Task {
                await viewModel.loadSelectedEntryDetail()
            }
        }
        .onChange(of: viewModel.group?.uri) { _, _ in
            Task {
                await viewModel.loadSelectedEntryDetail()
            }
        }
    }

    @ViewBuilder
    private var loadMoreTrigger: some View {
        ScrollViewReader { proxy in
            if viewModel.hasMore {
                ProgressView()
                    .padding()
                    .id(viewModel.children.count)
                    .scaleEffect(0.8)
                    .onAppear {
                        Task {
                            await viewModel.loadNextPage()
                        }
                    }
                    .onChange(of: viewModel.children.count) { _, newCount in
                        withAnimation {
                            proxy.scrollTo(newCount, anchor: .bottom)
                        }
                    }
            }
        }
    }

    @ViewBuilder
    private var tableContent: some View {
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
                if child.isGroup {
                    TableRow(child)
                        .draggable(EntryUri(uri: child.uri))
                        .dropDestination(for: URL.self) { urls in
                            Task {
                                let _ = await viewModel.moveChildrenToGroup(entryURLs: urls, newParentUri: child.uri)
                            }
                        }
                } else {
                    TableRow(child)
                        .draggable(EntryUri(uri: child.uri))
                        .dropDestination(for: URL.self) { urls in
                            Task {
                                let _ = await viewModel.moveChildrenToGroup(entryURLs: urls, newParentUri: child.uri)
                            }
                        }
                }
            }
        }
        .onChange(of: order) { newOrder in
            withAnimation {
                viewModel.sortChildren(by: newOrder)
            }
        }
    }

    @ViewBuilder
    private var inspectorSection: some View {
        if let entry = viewModel.inspectorEntryDetail {
            Divider()
            InspectorView(entry: entry, viewModel: viewModel)
                .frame(width: 280)
                .background(Color(NSColor.controlBackgroundColor))
        }
    }

    @ViewBuilder
    private var documentViewSection: some View {
        if let entry = viewModel.selectedEntryDetail {
            Divider()
            ResizableDocumentView(entry: entry, viewModel: viewModel)
                .frame(height: viewModel.documentViewHeight)
        }
    }
}


private struct ResizableDocumentView: View {
    let entry: EntryDetail
    let viewModel: GroupTableViewModel

    @State private var isDragging = false

    var body: some View {
        VStack(spacing: 0) {
            dragHandle
            documentContent
        }
    }

    private var dragHandle: some View {
        Rectangle()
            .fill(isDragging ? Color(NSColor.selectedControlColor) : Color(NSColor.separatorColor))
            .frame(height: 4)
            .overlay(alignment: .center) {
                RoundedRectangle(cornerRadius: 1)
                    .fill(Color(NSColor.disabledControlTextColor).opacity(0.5))
                    .frame(width: 30, height: 2)
            }
            .contentShape(Rectangle())
            .gesture(
                DragGesture()
                    .onChanged { value in
                        isDragging = true
                        let newHeight = viewModel.documentViewHeight - value.translation.height
                        viewModel.documentViewHeight = min(
                            max(newHeight, viewModel.minDocumentViewHeight),
                            viewModel.maxDocumentViewHeight
                        )
                    }
                    .onEnded { _ in
                        isDragging = false
                    }
            )
            .onHover { hovering in
                if hovering {
                    NSCursor.resizeUpDown.push()
                } else {
                    NSCursor.pop()
                }
            }
    }

    private var documentContent: some View {
        VStack(spacing: 0) {
            HStack {
                Text("\(entry.documentTitle ?? entry.name)")
                    .font(.headline)
                Spacer()
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
            .background(Color(NSColor.controlBackgroundColor))

            Divider()

            if entry.isGroup || viewModel.selectedEntryDetail?.uri == nil {
                Text("No document selected")
                    .foregroundColor(.gray)
                    .frame(maxHeight: .infinity)
            } else {
                DocumentReadContainerView(entryUri: viewModel.selectedEntryDetail!.uri, store: viewModel.store, fileRepository: viewModel.fileRepository, documentUsecase: viewModel.documentUsecase, fridayUseCase: viewModel.fridayUseCase)
                    .id(viewModel.selectedEntryDetail!.uri)
                    .frame(maxHeight: .infinity)
            }
        }
    }
}


private struct DocumentReadContainerView: View {
    let entryUri: String
    let store: StateStore
    let fileRepository: FileRepositoryProtocol
    let documentUsecase: any DocumentUseCaseProtocol
    let fridayUseCase: FridayUseCaseProtocol

    @State private var viewModel: DocumentReadViewModel?

    var body: some View {
        Group {
            if let vm = viewModel {
                DocumentReadView(viewModel: vm)
            } else {
                ProgressView("Loading...")
                    .onAppear {
                        viewModel = DocumentReadViewModel(
                            uri: entryUri,
                            store: store,
                            usecase: documentUsecase,
                            fileRepository: fileRepository,
                            fridayUseCase: fridayUseCase
                        )
                    }
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

private struct InspectorView: View {
    let entry: EntryDetail
    @Bindable var viewModel: GroupTableViewModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                basicInfoSection

                if entry.isGroup {
                    Divider()
                    groupConfigSection
                }

                if !entry.isGroup {
                    Divider()
                    documentInfoSection
                    Divider()
                    propertiesSection
                }

                Divider()
                timeInfoSection

                Spacer(minLength: 15)
            }
            .padding()
        }
        .frame(minWidth: 260)
        .background(Color(NSColor.windowBackgroundColor))
    }

    private var basicInfoSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Basic")
                .font(.headline)
                .foregroundColor(.secondary)

            InspectorPropertyRow(label: "Name", value: entry.name, isReadOnly: true)
            InspectorPropertyRow(label: "Kind", value: entry.kind, isReadOnly: true)
            InspectorPropertyRow(label: "Size", value: bytesToHumanReadableString(bytes: entry.size), isReadOnly: true)
            InspectorPropertyRow(label: "URI", value: entry.uri, isReadOnly: true)
        }
    }

    private var groupConfigSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Group Config")
                    .font(.headline)
                    .foregroundColor(.secondary)
                Spacer()
                if isEditingGroupConfig {
                    Button("Save") {
                        saveGroupConfig()
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.small)
                    Button("Cancel") {
                        cancelGroupConfigEditing()
                    }
                    .controlSize(.small)
                } else {
                    Button("Edit") {
                        loadGroupConfigEditingValues()
                        isEditingGroupConfig = true
                    }
                    .controlSize(.small)
                }
            }

            if let config = viewModel.inspectorGroupConfig {
                if config.source == "rss", let rss = config.rss {
                    rssConfigContent(rss: rss)
                } else if let filter = config.filter {
                    filterConfigContent(filter: filter)
                } else {
                    Text("No configuration")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            } else if viewModel.group != nil {
                Text("Loading...")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .onChange(of: entry.uri) { _, _ in
            isEditingGroupConfig = false
        }
    }

    private func rssConfigContent(rss: RSSConfig) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            if isEditingGroupConfig {
                EditablePropertyRow(label: "Feed", value: $editedRSSFeed, isEditing: isEditingGroupConfig, isReadOnly: false)
                EditablePropertyRow(label: "Site Name", value: $editedRSSSiteName, isEditing: isEditingGroupConfig, isReadOnly: false)
                EditablePropertyRow(label: "Site URL", value: $editedRSSSiteURL, isEditing: isEditingGroupConfig, isReadOnly: false)

                VStack(alignment: .leading, spacing: 2) {
                    Text("File Type")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Picker("File Type", selection: $editedRSSFileType) {
                        Text("HTML").tag("html")
                        Text("WebArchive").tag("webarchive")
                    }
                    .pickerStyle(.menu)
                    .controlSize(.small)
                }
            } else {
                InspectorPropertyRow(label: "Feed", value: rss.feed, isReadOnly: true)
                InspectorPropertyRow(label: "Site Name", value: rss.siteName, isReadOnly: true)
                InspectorPropertyRow(label: "Site URL", value: rss.siteURL, isReadOnly: true)
                InspectorPropertyRow(label: "File Type", value: rss.fileType.rawValue, isReadOnly: true)
            }
        }
    }

    private func filterConfigContent(filter: FilterConfig) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text("CEL Pattern")
                .font(.caption)
                .foregroundColor(.secondary)
            if isEditingGroupConfig {
                TextEditor(text: $editedFilterPattern)
                    .font(.caption)
                    .frame(height: 80)
                    .scrollContentBackground(.hidden)
                    .background(Color(NSColor.textBackgroundColor))
            } else {
                Text(filter.celPattern)
                    .font(.caption)
                    .textSelection(.enabled)
            }
        }
    }

    private func loadGroupConfigEditingValues() {
        guard let config = viewModel.selectedGroupConfig else { return }

        if config.source == "rss", let rss = config.rss {
            editedRSSFeed = rss.feed
            editedRSSSiteName = rss.siteName
            editedRSSSiteURL = rss.siteURL
            editedRSSFileType = rss.fileType.rawValue
        } else if let filter = config.filter {
            editedFilterPattern = filter.celPattern
        }
    }

    private func cancelGroupConfigEditing() {
        isEditingGroupConfig = false
        loadGroupConfigEditingValues()
    }

    private func saveGroupConfig() {
        guard let config = viewModel.selectedGroupConfig else { return }

        if config.source == "rss" {
            let rss = RSSConfig(
                feed: editedRSSFeed,
                siteName: editedRSSSiteName,
                siteURL: editedRSSSiteURL,
                fileType: FileType(rawValue: editedRSSFileType) ?? .html
            )
            Task {
                await viewModel.updateGroupConfig(uri: entry.uri, rss: rss, filter: nil)
            }
        } else if config.filter != nil {
            let filter = FilterConfig(celPattern: editedFilterPattern)
            Task {
                await viewModel.updateGroupConfig(uri: entry.uri, rss: nil, filter: filter)
            }
        }

        isEditingGroupConfig = false
    }

    private var timeInfoSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Time")
                .font(.headline)
                .foregroundColor(.secondary)

            InspectorPropertyRow(label: "Created", value: formatDate(entry.createdAt), isReadOnly: true)
            InspectorPropertyRow(label: "Changed", value: formatDate(entry.changedAt), isReadOnly: true)
            InspectorPropertyRow(label: "Modified", value: formatDate(entry.modifiedAt), isReadOnly: true)
            InspectorPropertyRow(label: "Accessed", value: formatDate(entry.accessAt), isReadOnly: true)
        }
    }

    @State private var editedTitle: String = ""
    @State private var editedAuthor: String = ""
    @State private var editedYear: String = ""
    @State private var editedSource: String = ""
    @State private var editedAbstract: String = ""
    @State private var editedNotes: String = ""
    @State private var editedURL: String = ""
    @State private var editedKeywords: String = ""
    @State private var isEditing: Bool = false

    // Properties editing state
    @State private var editedTags: String = ""
    @State private var newPropertyKey: String = ""
    @State private var newPropertyValue: String = ""
    @State private var editingPropertyKey: String = ""
    @State private var editingPropertyValue: String = ""
    @State private var isEditingProperties: Bool = false

    // Group Config editing state
    @State private var isEditingGroupConfig: Bool = false
    @State private var editedRSSFeed: String = ""
    @State private var editedRSSSiteName: String = ""
    @State private var editedRSSSiteURL: String = ""
    @State private var editedRSSFileType: String = ""
    @State private var editedFilterPattern: String = ""

    private var documentInfoSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Document")
                    .font(.headline)
                    .foregroundColor(.secondary)
                Spacer()
                if isEditing {
                    Button("Save") {
                        saveDocumentMetadata()
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.small)
                    Button("Cancel") {
                        cancelEditing()
                    }
                    .controlSize(.small)
                } else {
                    Button("Edit") {
                        loadEditingValues()
                        isEditing = true
                    }
                    .controlSize(.small)
                }
            }

            EditablePropertyRow(label: "Title", value: $editedTitle, isEditing: isEditing, isReadOnly: false)
            EditablePropertyRow(label: "Author", value: $editedAuthor, isEditing: isEditing, isReadOnly: false)
            EditablePropertyRow(label: "Year", value: $editedYear, isEditing: isEditing, isReadOnly: false)
            EditablePropertyRow(label: "Source", value: $editedSource, isEditing: isEditing, isReadOnly: false)

            VStack(alignment: .leading, spacing: 2) {
                Text("Abstract")
                    .font(.caption)
                    .foregroundColor(.secondary)
                if isEditing {
                    TextEditor(text: $editedAbstract)
                        .font(.caption)
                        .frame(height: 100)
                        .scrollContentBackground(.hidden)
                        .background(Color(NSColor.textBackgroundColor))
                } else if let abstract = entry.documentAbstract, !abstract.isEmpty {
                    Text(abstract)
                        .font(.caption)
                        .textSelection(.enabled)
                } else {
                    Text("-")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            VStack(alignment: .leading, spacing: 2) {
                Text("Notes")
                    .font(.caption)
                    .foregroundColor(.secondary)
                if isEditing {
                    TextEditor(text: $editedNotes)
                        .font(.caption)
                        .frame(height: 120)
                        .scrollContentBackground(.hidden)
                        .background(Color(NSColor.textBackgroundColor))
                } else if let notes = entry.documentNotes, !notes.isEmpty {
                    Text(notes)
                        .font(.caption)
                        .textSelection(.enabled)
                } else {
                    Text("-")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            EditablePropertyRow(label: "URL", value: $editedURL, isEditing: isEditing, isReadOnly: false)
            EditablePropertyRow(label: "Keywords", value: $editedKeywords, isEditing: isEditing, isReadOnly: false, placeholder: "comma separated")

            if let siteName = entry.documentSiteName {
                EditablePropertyRow(label: "Site Name", value: .constant(siteName), isEditing: false, isReadOnly: true)
            }
            if let siteURL = entry.documentSiteURL {
                EditablePropertyRow(label: "Site URL", value: .constant(siteURL), isEditing: false, isReadOnly: true)
            }
        }
        .onAppear {
            loadEditingValues()
        }
        .onChange(of: entry.uri) { _, _ in
            loadEditingValues()
            isEditing = false
        }
    }

    private var propertiesSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Properties")
                    .font(.headline)
                    .foregroundColor(.secondary)
                Spacer()
                if isEditingProperties {
                    Button("Done") {
                        saveProperties()
                    }
                    .controlSize(.small)
                } else {
                    Button("Edit") {
                        loadPropertiesEditingValues()
                        isEditingProperties = true
                    }
                    .controlSize(.small)
                }
            }

            // Tags section
            VStack(alignment: .leading, spacing: 4) {
                Text("Tags")
                    .font(.caption)
                    .foregroundColor(.secondary)
                if isEditingProperties {
                    TextField("comma separated", text: $editedTags)
                        .font(.caption)
                        .controlSize(.small)
                } else {
                    let tags = entry.property?.tags?.joined(separator: ", ")
                    Text(tags ?? "-")
                        .font(.caption)
                        .textSelection(.enabled)
                }
            }
            
            Spacer(minLength: 5)

            // Custom properties
            VStack(alignment: .leading, spacing: 4) {
                Text("Custom Properties")
                    .font(.caption)
                    .foregroundColor(.secondary)

                if isEditingProperties {
                    // Add new property
                    HStack {
                        TextField("key", text: $newPropertyKey)
                            .font(.caption)
                            .controlSize(.small)
                            .frame(width: 100)
                            .bold()
                        TextField("value", text: $newPropertyValue)
                            .font(.caption)
                            .controlSize(.small)
                        Button("+") {
                            addNewProperty()
                        }
                        .controlSize(.small)
                    }
                }

                ForEach(Array((entry.property?.properties ?? [:]).keys), id: \.self) { key in
                    if let value = entry.property?.properties?[key] {
                        HStack {
                            if isEditingProperties && editingPropertyKey == key {
                                TextField("key", text: $editingPropertyKey)
                                    .font(.caption)
                                    .controlSize(.small)
                                    .frame(width: 100)
                                    .bold()
                                TextField("value", text: $editingPropertyValue)
                                    .font(.caption)
                                    .controlSize(.small)
                                Button("✓") {
                                    savePropertyEdit(key)
                                }
                                .controlSize(.small)
                            } else {
                                Text(key)
                                    .font(.caption)
                                    .frame(width: 100, alignment: .leading)
                                Text(value)
                                    .font(.caption)
                                    .textSelection(.enabled)
                                if isEditingProperties {
                                    Button("✎") {
                                        startEditingProperty(key: key, value: value)
                                    }
                                    .controlSize(.small)
                                    Button("×") {
                                        deleteProperty(key)
                                    }
                                    .controlSize(.small)
                                    .foregroundColor(.red)
                                }
                            }
                        }
                    }
                }
            }

            if (entry.property?.properties?.isEmpty ?? true) && !isEditingProperties {
                Text("No properties")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

        }
        .onAppear {
            loadPropertiesEditingValues()
        }
        .onChange(of: entry.uri) { _, _ in
            loadPropertiesEditingValues()
            isEditingProperties = false
        }
        .onChange(of: entry.property?.properties?.count ?? 0) { _, _ in
            loadPropertiesEditingValues()
        }
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }

    private func loadEditingValues() {
        editedTitle = entry.documentTitle ?? ""
        editedAuthor = entry.documentAuthor ?? ""
        editedYear = entry.documentYear ?? ""
        editedSource = entry.documentSource ?? ""
        editedAbstract = entry.documentAbstract ?? ""
        editedNotes = entry.documentNotes ?? ""
        editedURL = entry.documentURL ?? ""
        editedKeywords = entry.documentKeywords?.joined(separator: ", ") ?? ""
    }

    private func cancelEditing() {
        isEditing = false
    }

    private func saveDocumentMetadata() {
        var update = DocumentUpdate()
        update.title = editedTitle.isEmpty ? nil : editedTitle
        update.author = editedAuthor.isEmpty ? nil : editedAuthor
        update.year = editedYear.isEmpty ? nil : editedYear
        update.source = editedSource.isEmpty ? nil : editedSource
        update.abstract = editedAbstract.isEmpty ? nil : editedAbstract
        update.notes = editedNotes.isEmpty ? nil : editedNotes
        update.url = editedURL.isEmpty ? nil : editedURL
        update.keywords = editedKeywords.isEmpty ? nil : editedKeywords.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }

        Task {
            await viewModel.updateDocumentMetadata(uri: entry.uri, update: update)
        }
        isEditing = false
    }

    // MARK: - Properties Editing

    private func loadPropertiesEditingValues() {
        let tags = entry.property?.tags?.joined(separator: ", ")
        editedTags = tags ?? ""
    }

    private func startEditingProperty(key: String, value: String) {
        editingPropertyKey = key
        editingPropertyValue = value
    }

    private func addNewProperty() {
        guard !newPropertyKey.isEmpty && !newPropertyValue.isEmpty else { return }
        Task {
            await viewModel.addProperty(uri: entry.uri, key: newPropertyKey, value: newPropertyValue)
            newPropertyKey = ""
            newPropertyValue = ""
        }
    }

    private func savePropertyEdit(_ oldKey: String) {
        guard !editingPropertyKey.isEmpty && !editingPropertyValue.isEmpty else { return }
        Task {
            if oldKey != editingPropertyKey {
                await viewModel.deleteProperty(uri: entry.uri, key: oldKey)
            }
            await viewModel.updateProperty(uri: entry.uri, key: editingPropertyKey, value: editingPropertyValue)
            editingPropertyKey = ""
            editingPropertyValue = ""
        }
    }

    private func deleteProperty(_ key: String) {
        Task {
            await viewModel.deleteProperty(uri: entry.uri, key: key)
        }
    }

    private func saveProperties() {
        // Save tags
        let currentTags = entry.property?.tags ?? []
        let newTags = editedTags.isEmpty ? [] : editedTags.split(separator: ",").map { String($0.trimmingCharacters(in: .whitespaces)) }
        if currentTags != newTags {
            Task {
                await viewModel.updateTags(uri: entry.uri, tags: newTags)
            }
        }
        isEditingProperties = false
    }
}


private struct InspectorPropertyRow: View {
    let label: String
    let value: String
    var isReadOnly: Bool = true

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
            Text(value)
                .font(.caption)
                .textSelection(.enabled)
        }
    }
}


private struct EditablePropertyRow: View {
    let label: String
    @Binding var value: String
    var isEditing: Bool = false
    var isReadOnly: Bool = true
    var placeholder: String = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)

            if isEditing && !isReadOnly {
                TextField(placeholder.isEmpty ? label : placeholder, text: $value)
                    .font(.caption)
                    .textFieldStyle(.plain)
                    .controlSize(.small)
            } else if !value.isEmpty {
                Text(value)
                    .font(.caption)
                    .textSelection(.enabled)
            } else {
                Text("-")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
}
