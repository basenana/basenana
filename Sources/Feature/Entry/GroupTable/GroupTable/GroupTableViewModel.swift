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

    var selection: Set<EntryRow.ID> = []
    var selectedDocument: EntryDetail? = nil

    // Panel visibility states
    var showInspector: Bool = false
    var showDocumentView: Bool = false
    var selectedEntryDetail: EntryDetail? = nil

    // Document view height (resizable)
    var documentViewHeight: CGFloat = 500
    let minDocumentViewHeight: CGFloat = 100
    let maxDocumentViewHeight: CGFloat = 600

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

            reset()
            await loadNextPage()
        } catch let error as UseCaseError where error == .canceled {
            // do nothing
        } catch {
            sentAlert("open group failed: \(error)")
        }
    }
}
