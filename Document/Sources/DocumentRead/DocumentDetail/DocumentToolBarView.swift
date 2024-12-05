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
        if let u = viewModel.targetURL {
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
