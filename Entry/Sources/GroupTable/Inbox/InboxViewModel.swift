//
//  InboxViewModel.swift
//  Entry
//
//  Created by Hypo on 2024/12/2.
//

import SwiftUI
import WebKit
import AppState
import Entities
import WebPage
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
        
        NotificationCenter.default.post(name: .reopenGroup, object: [groupTree.inbox.id])
        return true
    }
    
    func packingWebPage(url: String, title: String, webView: WKWebView) async -> (String, Bool) {
        
        guard let u = URL(string: url) else {
            return ("invalid url", false)
        }
        
        do {
            let value = try await webView.evaluateJavaScript("document.documentElement.outerHTML.toString()")
            if let htmlContent = value as? String{
                 webarchiveAndUpload(url: u, title: title, content: htmlContent)
                return ("", true)
            }else {
                return ("load html content failed: not a string", false)
            }
        }catch {
            return ("load html content error \(error)", false)
            
        }
    }
    
    func webarchiveAndUpload(url: URL, title: String, content: String)  {
        
        store.newBackgroundJob(
            name: "web archiving \(title)",
            job: {
                Task {
                    let temporaryDirectory = FileManager.default.temporaryDirectory
                    let temporaryFileName = "\(title).webarchive"
                    let temporaryFileURL = temporaryDirectory.appendingPathComponent(temporaryFileName)
                    
                    do {
                        try webarchiveBaseMainResource(url: url, mainResource: content, temporaryFileURL: temporaryFileURL)
                    } catch {
                        print("save error \(error)")
                    }
                }
            },
            complete: {
            }
        )
        
    }
}
