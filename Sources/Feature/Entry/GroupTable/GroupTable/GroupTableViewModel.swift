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

    var selection: Set<EntryRow.ID> = []
    var selectedDocument: DocumentDetail? = nil

    override public init(store: StateStore, entryUsecase: any EntryUseCaseProtocol) {
        super.init(store: store, entryUsecase: entryUsecase)
    }
    
    var selectedEntries: [EntryInfo] {
        get {
            children.filter( { selection.contains($0.id)} ).map({ $0.info })
        }
    }
    
    func openGroup(groupID: Int64) async {
        do {
            group = try await entryUsecase.getEntryDetails(entry: groupID)
            if group == nil || !group!.isGroup {
                throw BizError.notGroup
            }
            
            self.children = []
            let newChildren = try await entryUsecase.listChildren(entry: groupID)
            for child in newChildren {
                self.children.append(EntryRow(info: child))
            }
        } catch let error as UseCaseError where error == .canceled {
            // do nothing
        } catch {
            sentAlert("open group failed: \(error)")
        }
    }
}
