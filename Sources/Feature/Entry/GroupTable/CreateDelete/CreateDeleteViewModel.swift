//
//  CreateDeleteViewModel.swift
//  Entry
//
//  Created by Hypo on 2024/11/28.
//

import os
import SwiftUI
import Domain
import Domain
import Domain


@Observable
@MainActor
public class CreateDeleteViewModel {
    var store: StateStore
    var entryUsecase: any EntryUseCaseProtocol

    private static let logger = Logger(
            subsystem: Bundle.main.bundleIdentifier!,
            category: String(describing: CreateDeleteViewModel.self)
        )

    public init(store: StateStore, entryUsecase: any EntryUseCaseProtocol) {
        self.store = store
        self.entryUsecase = entryUsecase
    }

    func describeEntry(uri: String) async -> EntryDetail? {
        do {
            return try await entryUsecase.getEntryDetails(uri: uri)
        } catch let error as UseCaseError where error == .canceled {
            // do nothing
        } catch {
            sentAlert("describe entry failed: \(error)")
        }
        return nil
    }

    func createGroup(parentUri: String, option: EntryCreate, onCreated: ((EntryInfo) -> Void)? = nil) async {
        let isRoot = parentUri.isEmpty || parentUri == EntryURI.root
        let effectiveParentUri = isRoot ? "" : parentUri

        guard isRoot || store.getTreeGroup(uri: parentUri) != nil else {
            sentAlert("create group failed: parent \(parentUri) not exist")
            return
        }

        do {
            let newGroup = try await entryUsecase.createGroups(parentUri: effectiveParentUri, option: option)
            // UseCase has already updated Store cache
            onCreated?(newGroup)
            NotificationCenter.default.post(name: .reopenGroup, object: [effectiveParentUri])
        } catch {
            sentAlert("create group failed: \(error)")
            return
        }
    }

    func deleteEntries(entries: [EntryInfo], onDeleted: (([Int64]) -> Void)? = nil) {
        let uc = entryUsecase
        let st = store
        let ids = entries.map { $0.id }

        for entry in entries {
            store.newBackgroundJob(
                name: "Deleting \(entry.name)",
                job: {
                    do {
                        try await uc.deleteEntry(uri: entry.uri)
                    } catch {
                        sentAlert("delete entry \(entry.name) failed \(error)")
                        return
                    }
                },
                complete: {
                    // Remove from Tree cache
                    if entry.isGroup {
                        st.removeTreeChildGroup(parentUri: entry.uri, childUri: entry.uri)
                    }
                    // Notify views to refresh children
                    NotificationCenter.default.post(name: .childrenChanged, object: ChildrenChange(parentUri: "", changeType: .delete))
                    NotificationCenter.default.post(name: .reopenGroup, object: [entry.uri])
                }
            )
        }

        onDeleted?(ids)
    }
}
