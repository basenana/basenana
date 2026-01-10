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

    override public init(store: StateStore, entryUsecase: any EntryUseCaseProtocol) {
        super.init(store: store, entryUsecase: entryUsecase)
    }
    
    var selectedEntries: [EntryInfo] {
        get {
            children.filter( { selection.contains($0.id)} ).map({ $0.info })
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
            let newChildren = try await entryUsecase.listChildren(uri: group.uri, page: page, pageSize: pageSize)
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
