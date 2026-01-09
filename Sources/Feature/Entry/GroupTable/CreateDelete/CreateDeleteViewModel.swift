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
    var groupTree = GroupTree.shared

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

    func createGroup(parentUri: String, option: EntryCreate) async {
        guard groupTree.getGroup(uri: parentUri) != nil else {
            sentAlert("creatr group failed: parent \(parentUri) not exist")
            return
        }

        do {
            let newGroup = try await entryUsecase.createGroups(parentUri: parentUri, option: option)
            groupTree.addChildGroup(parentUri: parentUri, child: newGroup.toGroup()!, grandChildren: nil)
            NotificationCenter.default.post(name: .reopenGroup, object: [parentUri])
        } catch {
            sentAlert("creatr group failed: \(error)")
            return
        }
    }

    func deleteEntries(entries: [EntryInfo]) async {
        let uc = entryUsecase
        let gt = groupTree

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
                    for entry in entries {
                        if entry.isGroup {
                            gt.removeChildGroup(parentUri: entry.uri, childUri: entry.uri)
                        }
                        NotificationCenter.default.post(name: .reopenGroup, object: [entry.uri])
                    }
                }
            )

        }
    }
}
