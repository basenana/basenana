//
//  EntryDetailViewModel.swift
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
public class EntryDetailViewModel {
    var groupTree = GroupTree.shared
    
    var store: StateStore
    var entryUsecase: EntryUseCaseProtocol
    
    var errorMessage: String = ""
    
    private static let logger = Logger(
            subsystem: Bundle.main.bundleIdentifier!,
            category: String(describing: EntryDetailViewModel.self)
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
    
    func renameEntry(entry: EntryDetail, newName: String) async -> Bool {
        Self.logger.notice("rename entry \(entry.name) = > \(newName)")
        if entry.name == newName {
            return true
        }
        
        let validName = sanitizeFileName(newName)
        if validName != newName {
            errorMessage = "\(newName) is invalid"
            return false
        }
        
        do {
            try await entryUsecase.renameEntry(entry: entry.id, newName: validName)
            if entry.isGroup {
                let entryDetail = try await entryUsecase.getEntryDetails(entry: entry.id)
                if let grp = groupTree.getGroup(groupID: entry.id){
                    groupTree.removeChildGroup(parentID: grp.parentID, childID: entry.id)
                    groupTree.addChildGroup(parentID: grp.parentID, child: entryDetail.toGroup()!, grandChildren: grp.children)
                }
            }
            
            NotificationCenter.default.post(name: .reopenGroup, object: [entry.parent])
        } catch {
            errorMessage = "rename failed \(error)"
            return false
        }
        
        return true
    }
}
