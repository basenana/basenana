//
//  InboxViewModel.swift
//  Entry
//
//  Created by Hypo on 2024/12/2.
//

import SwiftUI
import AppState
import Entities
import UseCaseProtocol


@Observable
@MainActor
public class InboxViewModel: BaseViewModel {
    
    override public init(store: StateStore, entryUsecase: EntryUseCaseProtocol) {
        super.init(store: store, entryUsecase: entryUsecase)
    }
    
    // quick inbox
    func quickInbox(url: String, title: String, fileType: String, errorMsg: Binding<String>) async -> Bool {
        var safeFileType: Entities.FileType = .Webarchive
        switch fileType{
        case "html":
            safeFileType = .Html
        case "webarchive":
            safeFileType = .Webarchive
        default:
            safeFileType = .Webarchive
        }
        do {
            print("quick inbox url=\(url) fileName=\(title) fileType=\(safeFileType)")
            try await entryUsecase.quickInbox(url: url, fileName: sanitizeFileName(title), fileType: safeFileType)
        } catch {
            errorMsg.wrappedValue = "inbox failed: \(error)"
            return false
        }
        
        groupState.requestReopen()
        return true
    }
    
    func packingWebPage(url: String, title: String, errorMsg: Binding<String>) async -> Bool {
        return false
    }
}
