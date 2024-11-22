//
//  FileMenuView.swift
//  Entry
//
//  Created by Hypo on 2024/10/10.
//

import Foundation
import SwiftUI
import Entities
import AppState
import UseCaseProtocol


@available(macOS 14.0, *)
struct FileMenuView: View {
    private var viewModel: TreeViewModel
    private var targetEntry: EntryDetail
    
    init(viewModel: TreeViewModel, targetEntry: EntryDetail) {
        self.viewModel = viewModel
        self.targetEntry = targetEntry
    }
    
    var body: some View {
        // web file
        if let u = parseUrlString(urlStr: getEntryProperty(keys: [Property.WebPageURL, Property.WebSiteURL])?.value ?? "" ){
            Section(){
                Button("Launch URL", action: {
                    openUrlInBrowser(url: u)
                })
                Button("Copy URL", action: {
                    copyToClipBoard(content: "\(u)")
                })
            }
        }
    }
    
    func getEntryProperty(keys: [String]) -> EntryProperty?{
        for k in keys {
            for p in targetEntry.properties {
                if p.key == k {
                    return p
                }
            }
        }
        return nil
    }
}
