//
//  EntryDetailViewModel.swift
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
public class EntryDetailViewModel {
    var groupTree = GroupTree.shared
    var groupState = GroupState.shared
    
    var store: StateStore
    var entryUsecase: EntryUseCaseProtocol
    
    public init(store: StateStore, entryUsecase: EntryUseCaseProtocol) {
        self.store = store
        self.entryUsecase = entryUsecase
    }
}
