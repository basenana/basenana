//
//  MenuViewModel.swift
//  Entry
//
//  Created by Hypo on 2024/10/10.
//

import Foundation
import SwiftUI
import Entities
import AppState


@available(macOS 14.0, *)
@Observable
@MainActor
public class MenuViewModel {
    
    var entry: EntryInfo?
    var group: Entities.Group?
    
    var store: StateStore
    
    public init(store: StateStore, entry: EntryInfo? = nil) {
        self.store = store
        self.entry = entry
        self.group = entry?.toGroup()
    }
    
    func getProperty(k: String) -> String? {
        return ""
    }
    
    func initEntryCache() async throws {
        
    }
}
