//
//  GroupTableViewModel.swift
//  Entry
//
//  Created by Hypo on 2024/11/27.
//

import os
import SwiftUI
import Domain
import Domain
import Domain


@Observable
@MainActor
public class GroupTableViewModel: BaseViewModel {

    var group: EntryDetail? = nil
    var children: [EntryRow] = []

    var page: Int = 1
    var pageSize: Int = 50
    var hasMore: Bool = true
    var isLoading: Bool = false

    // Internal selection storage
    private var _selection: Set<EntryRow.ID> = [] {
        didSet {
            updateSelectionState()
        }
    }

    // Exposed selection property
    var selection: Set<EntryRow.ID> {
        get { _selection }
        set { _selection = newValue }
    }

    var selectedDocument: EntryDetail? = nil

    // Panel visibility states (from global StateStore)
    var showInspector: Bool { store.showInspector }
    var showDocumentView: Bool { store.showDocumentView }
    var selectedEntryDetail: EntryDetail? = nil

    // Document view height (resizable)
    var documentViewHeight: CGFloat = 500
    let minDocumentViewHeight: CGFloat = 100
    let maxDocumentViewHeight: CGFloat = 1000

    // Dependencies
    var fileRepository: FileRepositoryProtocol
    var documentUsecase: any DocumentUseCaseProtocol

    public init(store: StateStore, entryUsecase: any EntryUseCaseProtocol, fileRepository: FileRepositoryProtocol, documentUsecase: any DocumentUseCaseProtocol) {
        self.fileRepository = fileRepository
        self.documentUsecase = documentUsecase
        super.init(store: store, entryUsecase: entryUsecase)
    }

    var selectedEntries: [EntryInfo] {
        get {
            children.filter( { selection.contains($0.id)} ).map({ $0.info })
        }
    }

    var canShowPanels: Bool {
        selection.count == 1 && {
            guard let id = selection.first,
                  let entry = children.first(where: { $0.id == id }) else {
                return false
            }
            return !entry.isGroup
        }()
    }

    // MARK: - Selection Change Handler
    private func updateSelectionState() {
        guard selection.count == 1, let id = selection.first,
              let entry = children.first(where: { $0.id == id }) else {
            store.selectedEntryUri = nil
            return
        }
        store.selectedEntryUri = entry.uri
    }

    func loadSelectedEntryDetail() async {
        guard selection.count == 1, let id = selection.first else {
            selectedEntryDetail = nil
            return
        }

        guard let entry = children.first(where: { $0.id == id }) else {
            selectedEntryDetail = nil
            return
        }

        if entry.isGroup {
            selectedEntryDetail = nil
            return
        }

        do {
            selectedEntryDetail = try await entryUsecase.getEntryDetails(uri: entry.uri)
        } catch {
            sentAlert("load entry detail failed: \(error)")
            selectedEntryDetail = nil
        }
    }

    func reset() {
        self.page = 1
        self.hasMore = true
        self.children = []
    }

    func loadNextPage() async {
        guard !isLoading && hasMore, let group = group else { return }
        isLoading = true
        defer { isLoading = false }

        do {
            let newChildren = try await entryUsecase.listChildren(uri: group.uri, page: page, pageSize: pageSize, sort: "name", order: "asc")
            if newChildren.isEmpty {
                hasMore = false
                return
            }

            for child in newChildren {
                self.children.append(EntryRow(info: child))
            }

            if newChildren.count < pageSize {
                hasMore = false
            } else {
                page += 1
                Task.detached { [weak self] in
                    await self?.loadNextPage()
                }
            }
        } catch {
            sentAlert("load more children failed: \(error)")
        }
    }

    func openGroup(uri: String) async {
        do {
            group = try await entryUsecase.getEntryDetails(uri: uri)
            if group == nil || !group!.isGroup {
                throw BizError.notGroup
            }

            // Sync with global navigation state
            store.currentGroupUri = uri

            reset()
            await loadNextPage()
        } catch let error as UseCaseError where error == .canceled {
            // do nothing
        } catch {
            sentAlert("open group failed: \(error)")
        }
    }

    // MARK: - Synchronous Update Methods

    func updateChild(id: Int64, newName: String, newUri: String) {
        if let index = children.firstIndex(where: { $0.id == id }) {
            children[index].name = newName
            children[index].uri = newUri
        }
    }

    func removeChildren(ids: [Int64]) {
        children.removeAll { ids.contains($0.id) }
    }

    func addChildren(infos: [EntryInfo]) {
        for info in infos {
            children.append(EntryRow(info: info))
        }
        children.sort { $0.name < $1.name }
    }

    // MARK: - Wrapper Methods

    func moveChildrenToGroup(entryUris: [String], newParentUri: String) async -> Bool {
        let success = await moveEntriesToGroup(entryUris: entryUris, newParentUri: newParentUri)
        if success {
            children.removeAll { entryUris.contains($0.uri) }
        }
        return success
    }

    func moveChildrenToGroup(entryURLs: [URL], newParentUri: String) async -> Bool {
        var entryUris: [String] = []
        var files = [URL]()

        for url in entryURLs {
            switch url.scheme {
            case "basenana":
                guard let targetUri = parseUriFromURL(url: url), !targetUri.isEmpty else {
                    sentAlert("\(url) not a valid entry")
                    continue
                }
                entryUris.append(targetUri)
            case "file":
                files.append(url)
            default:
                print("[moveChildrenToGroup] unknown url schema \(url)")
            }
        }

        if !entryUris.isEmpty {
            return await moveChildrenToGroup(entryUris: entryUris, newParentUri: newParentUri)
        }

        if !files.isEmpty {
            await uploadFilesToGroup(parentUri: newParentUri, files: files)
            return true
        }

        return false
    }

    private func parseUriFromURL(url: URL) -> String? {
        guard url.scheme == "basenana" else { return nil }
        var path = url.path
        if path.isEmpty {
            path = url.host ?? ""
        }

        if let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
           let queryItems = components.queryItems,
           let id = queryItems.first(where: { $0.name == "id" })?.value {
            return "\(path)/\(id)"
        }
        return path.isEmpty ? nil : path
    }

    func renameEntry(entry: EntryDetail, newName: String) async -> Bool {
        let vm = EntryDetailViewModel(store: store, entryUsecase: entryUsecase)

        return await vm.renameEntry(entry: entry, newName: newName) { [self] id, newName, newUri in
            updateChild(id: id, newName: newName, newUri: newUri)
        }
    }

    func createGroup(parentUri: String, option: EntryCreate) async {
        let vm = CreateDeleteViewModel(store: store, entryUsecase: entryUsecase)

        await vm.createGroup(parentUri: parentUri, option: option) { [self] info in
            if group?.uri == parentUri {
                addChildren(infos: [info])
            }
        }
    }

    func deleteEntries(entries: [EntryInfo]) async {
        let uris = entries.map { $0.uri }
        let vm = CreateDeleteViewModel(store: store, entryUsecase: entryUsecase)

        children.removeAll { uris.contains($0.uri) }

        await vm.deleteEntries(entries: entries) { deletedUris in
            // Already removed from children above
        }
    }

    func uploadFilesToGroup(parentUri: String, files: [URL]) async {
        let isCurrentGroup = group?.uri == parentUri

        for file in files {
            store.newBackgroundJob(
                name: "Uploading \(file.lastPathComponent)",
                job: { [self] in
                    do {
                        if try file.resourceValues(forKeys: [.isDirectoryKey]).isDirectory ?? false {
                            throw BizError.isGroup
                        }

                        let en = try await entryUsecase.UploadFile(
                            parentUri: parentUri,
                            file: file,
                            properties: nil,
                            tags: nil,
                            document: nil
                        )
                        print("upload new entry \(en.id)/\(en.name)")

                        if isCurrentGroup {
                            await MainActor.run {
                                addChildren(infos: [en])
                            }
                        }
                    } catch {
                        sentAlert("upload file \(file.lastPathComponent) failed \(error)")
                    }
                },
                complete: {
                    NotificationCenter.default.post(name: .reopenGroup, object: [parentUri])
                }
            )
        }
    }

    private func parentUri(of uri: String) -> String {
        let components = uri.split(separator: "/")
        guard components.count > 1 else { return "/" }
        let parentPath = components.dropLast().joined(separator: "/")
        return "/" + parentPath
    }

    // MARK: - Inspector Edit Methods

    func updateDocumentMetadata(uri: String, update: DocumentUpdate) async {
        do {
            try await documentUsecase.updateDocumentMetadata(uri: uri, update: update)
            await refreshSelectedEntryDetail()
        } catch {
            sentAlert("update document metadata failed: \(error)")
        }
    }

    func addProperty(uri: String, key: String, value: String) async {
        do {
            let entry = selectedEntryDetail
            var properties = entry?.property?.properties ?? [:]
            properties[key] = value
            let tags = entry?.property?.tags
            try await documentUsecase.setProperties(uri: uri, tags: tags, properties: properties)
            await refreshSelectedEntryDetail()
        } catch {
            sentAlert("add property failed: \(error)")
        }
    }

    func updateProperty(uri: String, key: String, value: String) async {
        do {
            let entry = selectedEntryDetail
            var properties = entry?.property?.properties ?? [:]
            properties[key] = value
            let tags = entry?.property?.tags
            try await documentUsecase.setProperties(uri: uri, tags: tags, properties: properties)
            await refreshSelectedEntryDetail()
        } catch {
            sentAlert("update property failed: \(error)")
        }
    }

    func deleteProperty(uri: String, key: String) async {
        do {
            let entry = selectedEntryDetail
            var properties = entry?.property?.properties ?? [:]
            properties.removeValue(forKey: key)
            let tags = entry?.property?.tags
            try await documentUsecase.setProperties(uri: uri, tags: tags, properties: properties)
            await refreshSelectedEntryDetail()
        } catch {
            sentAlert("delete property failed: \(error)")
        }
    }

    func updateTags(uri: String, tags: [String]) async {
        do {
            try await documentUsecase.updateTags(uri: uri, tags: tags)
            await refreshSelectedEntryDetail()
        } catch {
            sentAlert("update tags failed: \(error)")
        }
    }

    private func refreshSelectedEntryDetail() async {
        guard let entry = selectedEntryDetail else { return }
        do {
            selectedEntryDetail = try await entryUsecase.getEntryDetails(uri: entry.uri)
        } catch {
            sentAlert("refresh entry detail failed: \(error)")
        }
    }
}
