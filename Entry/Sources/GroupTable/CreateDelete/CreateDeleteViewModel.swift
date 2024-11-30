//
//  CreateDeleteViewModel.swift
//  Entry
//
//  Created by Hypo on 2024/11/28.
//
import SwiftUI
import AppState
import Entities
import UseCaseProtocol


@Observable
@MainActor
public class CreateDeleteViewModel {
    var groupTree = GroupTree.shared
    var groupState = GroupState.shared

    var store: StateStore
    var entryUsecase: EntryUseCaseProtocol
    
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
            store.alert.display(msg: "describe entry failed: \(error)")
        }
        return nil
    }
    
    func createGroup(parentID: Int64, option: EntryCreate) async {
        guard groupTree.getGroup(groupID: parentID) != nil else {
            store.alert.display(msg: "creatr group failed: parent \(parentID) not exist")
            return
        }
        
        do {
            let newGroup = try await entryUsecase.createGroups(parent: parentID, option: option)
            groupTree.addChildGroup(parentID: parentID, child: newGroup.toGroup()!, grandChildren: [])
            groupState.requestReopen()
        } catch {
            store.alert.display(msg: "creatr group failed: \(error)")
            return
        }
    }
    
    func deleteEntries(entries: [EntryInfo]) async {
        var jobIDs = Set<String>()
        let s = store
        let uc = entryUsecase
        let gs = groupState
        let gt = groupTree
        
        for entry in entries {
            let job = BackgroundJob(name: "Deleting \(entry.name)", startAt: Date())
            jobIDs.insert(job.id)
            s.backgroupJobs.append(job)
        }
        
        DispatchQueue.global().async {
            Task {
                try await uc.deleteEntries(entries: entries.map({$0.id}))
                DispatchQueue.main.sync {
                    for entry in entries {
                        if entry.isGroup {
                            gt.removeChildGroup(parentID: entry.parentID, childID: entry.id)
                        }
                    }
                    gs.requestReopen()
                    s.backgroupJobs.removeAll(where: { jobIDs.contains($0.id )})
                }
            }
        }
    }
}
