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

    func fetchAndUpload(url: String, title: String? = nil) {
        let useCase = FetchWebPageUseCase(entryUsecase: entryUsecase, setting: store.setting.general)
        store.newBackgroundJob(
            name: "Fetching \(url)",
            job: {
                do {
                    _ = try await useCase.execute(url: url, title: title)
                    Self.logger.info("fetch completed: \(url)")
                } catch {
                    Self.logger.error("fetch failed: \(error)")
                    Task { @MainActor in
                        sentAlert("Fetch failed: \(error)")
                    }
                }
            },
            complete: {
                NotificationCenter.default.post(name: .reopenGroup, object: [EntryURI.inbox])
            }
        )
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

        let document = DocumentCreate(title: title, url: url.absoluteString)

        store.newBackgroundJob(
            name: "Uploading Web Archive \(file.lastPathComponent)",
            job: {
                do {
                    if try file.resourceValues(forKeys: [.isDirectoryKey]).isDirectory ?? false {
                        sentAlert("invalid web file")
                        return
                    }
                    
                    let en = try await self.entryUsecase.UploadFile(
                        parentUri: EntryURI.inbox,
                        file: file,
                        properties: nil,
                        tags: nil,
                        document: document
                    )
                    Self.logger.info("upload new entry \(en.id)/\(en.name)")
                } catch {
                    sentAlert("upload file \(file.lastPathComponent) failed \(error)")
                }
            },
            complete: {
                NotificationCenter.default.post(name: .reopenGroup, object: [EntryURI.inbox])
            }
        )
    }
}
