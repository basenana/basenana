//
//  InboxViewModel.swift
//  Inbox
//
//  Created by Hypo on 2024/10/14.
//
import SwiftUI
import Foundation
import Entities
import UseCase
import WebPage
import AppState

@available(macOS 14.0, *)
@Observable
@MainActor
public class InboxViewModel {
    var selectedURL: String? = nil
    var htmlContent: String = ""
    
    var page: WebPage? = nil
    var errorMsg: String = ""
    
    var store: StateStore
    var usecase: InboxUseCase
    
    init(store: StateStore, usecase: InboxUseCase){
        self.store = store
        self.usecase = usecase
    }
    
    func doInbox(url: String, title: String, fileType: String) {
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
            try usecase.quickInbox(url: url, fileName: title, fileType: safeFileType)
        } catch {
            errorMsg = "inbox failed \(error)"
        }
    }
    
    func tryLoadWebPage(urlInput: String, urlTitle: Binding<String>) {
        if urlInput != ""{
            if let _ = URL(string: urlInput){
                Task{
                    do {
                        let loadedPage = try fetchWebPage(url: urlInput)
                        self.page = loadedPage
                        urlTitle.wrappedValue = self.page?.title ?? ""
                    }catch {
                        errorMsg = "fetch web page failed \(error)"
                    }
                }
            }
        }
    }
}
