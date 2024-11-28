//
//  GroupCreateViewModel.swift
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
public class GroupCreateViewModel {
    var groupTree = GroupTree.shared
    var groupState = GroupState.shared

    var store: StateStore
    var entryUsecase: EntryUseCaseProtocol
    
    public init(store: StateStore, entryUsecase: EntryUseCaseProtocol) {
        self.store = store
        self.entryUsecase = entryUsecase
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
}
