//
//  DocumentToolBarView.swift
//  Entry
//
//  Created by Hypo on 2024/11/28.
//
import Foundation
import SwiftUI
import Entities
import AppState
import Styleguide


struct DocumentToolBarView: View {
    @State private var viewModel: DocumentReadViewModel
    
    public init(viewModel: DocumentReadViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        // web file
        if let _ = viewModel.entry {
            if let u = targetURL {
                Button(action: {
                    openUrlInBrowser(url: u)
                }, label: {
                    Image(systemName: "safari")
                })
                
                Button(action: {
                    copyToClipBoard(content: "\(u.absoluteString)")
                    viewModel.store.dispatch(.alert(msg: "Link Copied"))
                }, label: {
                    Image(systemName: "link")
                })
            }
        }
    }
    
    var targetURL: URL? {
        get {
            if let pro = getEntryProperty(keys: [Property.WebPageURL, Property.WebSiteURL]) {
                if let u = URL(string: pro.value) {
                    return u
                }
            }
            return nil
        }
    }
    
    
    func getEntryProperty(keys: [String]) -> EntryProperty? {
        guard viewModel.entry != nil else {
            return nil
        }
        for k in keys {
            for p in viewModel.entry!.properties {
                if p.key == k {
                    return p
                }
            }
        }
        return nil
    }
}
