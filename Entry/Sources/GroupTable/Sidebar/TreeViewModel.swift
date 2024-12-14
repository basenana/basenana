//
//  TrewViewModel.swift
//  Entry
//
//  Created by Hypo on 2024/9/22.
//

import os
import SwiftUI
import AppState
import Entities
import UseCaseProtocol


@Observable
@MainActor
public class TreeViewModel: BaseViewModel {
    
    var selectedGroupId: Int64? = nil
    
    private static let logger = Logger(
            subsystem: Bundle.main.bundleIdentifier!,
            category: String(describing: TreeViewModel.self)
        )
    
    override public init(store: StateStore, entryUsecase: EntryUseCaseProtocol) {
        super.init(store: store, entryUsecase: entryUsecase)
    }
    
    func resetGroupTree() async {
        Self.logger.info("[resetGroupTree] load and reset group root")
        do {
            self.groupTree.reset(root: try await entryUsecase.getTreeRoot())
        } catch {
            sentAlert("load group tree failed: \(error)")
        }
    }
    
    
}
