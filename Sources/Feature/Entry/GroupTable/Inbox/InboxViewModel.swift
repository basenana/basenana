//
//  InboxViewModel.swift
//  Entry
//
//  Created by Hypo on 2024/12/2.
//

import os
import SwiftUI
import WebKit
import Domain
import Domain

import Domain


@Observable
@MainActor
public class InboxViewModel: BaseViewModel {
    
    private static let logger = Logger(
            subsystem: Bundle.main.bundleIdentifier!,
            category: String(describing: InboxViewModel.self)
        )
    
    override public init(store: StateStore, entryUsecase: EntryUseCaseProtocol) {
        super.init(store: store, entryUsecase: entryUsecase)
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
            name: "Packing Web Page \(title)",
            job: {
                let temporaryDirectory = FileManager.default.temporaryDirectory
                let temporaryFileName = "\(title).webarchive"
                let temporaryFileURL = temporaryDirectory.appendingPathComponent(temporaryFileName)
                
                do {
                    try webarchiveBaseMainResource(url: url, mainResource: content, temporaryFileURL: temporaryFileURL){ error in
                        if let err = error {
                            sentAlert("web packing failed \(err)")
                            return
                        }
                        DispatchQueue.main.async {
                            self.uploadWebarchive(url: url, title: title, file: temporaryFileURL)
                        }
                    }
                } catch {
                    Self.logger.info("save error \(error)")
                }
            },
            complete: {
            }
        )
        
    }
    
    func uploadWebarchive(url: URL, title: String, file: URL)  {
        assert(Thread.isMainThread)
        
        store.newBackgroundJob(
            name: "Uploading Web Archive \(file.lastPathComponent)",
            job: {
                let properties: [String:String] = [Property.WebPageURL:url.absoluteString, Property.WebPageTitle: title]
                do {
                    if try file.resourceValues(forKeys: [.isDirectoryKey]).isDirectory ?? false {
                        sentAlert("invalid web file")
                        return
                    }
                    
                    let en = try await self.entryUsecase.UploadFile(parentUri: EntryURI.inbox, file: file, properties: properties)
                    Self.logger.info("upload new entry \(en.id)/\(en.name)")
                } catch {
                    sentAlert("upload file \(file.lastPathComponent) failed \(error)")
                }
            },
            complete: {
                NotificationCenter.default.post(name: .reopenGroup, object: [self.store.fsInfo.inboxID])
            }
        )
    }
}
