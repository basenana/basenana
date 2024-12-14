//
//  CreateDeleteViewModel.swift
//  Entry
//
//  Created by Hypo on 2024/11/28.
//

import os
import SwiftUI
import AppState
import Entities
import UseCaseProtocol


@Observable
@MainActor
public class CreateDeleteViewModel {
    var groupTree = GroupTree.shared
    
    var store: StateStore
    var entryUsecase: EntryUseCaseProtocol
    
    private static let logger = Logger(
            subsystem: Bundle.main.bundleIdentifier!,
            category: String(describing: CreateDeleteViewModel.self)
        )
    
    public init(store: StateStore, entryUsecase: EntryUseCaseProtocol) {
        self.store = store
        self.entryUsecase = entryUsecase
    }
    
    func describeEntry(entry: Int64) async -> Entities.EntryDetail? {
        do {
            return try await entryUsecase.getEntryDetails(entry: entry)
        } catch let error as UseCaseError where error == .canceled {
            // do nothing
        } catch {
            sentAlert("describe entry failed: \(error)")
        }
        return nil
    }
    
    func createGroup(parentID: Int64, option: EntryCreate) async {
        guard groupTree.getGroup(groupID: parentID) != nil else {
            sentAlert("creatr group failed: parent \(parentID) not exist")
            return
        }
        
        do {
            let newGroup = try await entryUsecase.createGroups(parent: parentID, option: option)
            groupTree.addChildGroup(parentID: parentID, child: newGroup.toGroup()!, grandChildren: nil)
            NotificationCenter.default.post(name: .reopenGroup, object: [parentID])
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
                        try await uc.deleteEntry(entry: entry.id)
                    } catch {
                        sentAlert("delete entry \(entry.name) failed \(error)")
                        return
                    }
                },
                complete: {
                    for entry in entries {
                        if entry.isGroup {
                            gt.removeChildGroup(parentID: entry.parentID, childID: entry.id)
                        }
                        NotificationCenter.default.post(name: .reopenGroup, object: [entry.parentID])
                    }
                }
            )
            
        }
    }
}
