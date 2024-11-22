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
    private var target: EntryDetail
    
    init(viewModel: TreeViewModel, target: EntryDetail) {
        self.viewModel = viewModel
        self.target = target
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
            for p in target.properties {
                if p.key == k {
                    return p
                }
            }
        }
        return nil
    }
}
