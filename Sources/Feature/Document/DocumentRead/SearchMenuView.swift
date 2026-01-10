//
//  SearchMenuView.swift
//  Document
//
//  Created by Weiwei on 2025/4/12.
//

import SwiftUI
import Foundation
import Domain
import Styleguide

struct SearchMenuView: View {
    @Binding var document: DocumentSearchItem
    @State var viewModel: SearchViewModel

    init(document: Binding<DocumentSearchItem>, viewModel: SearchViewModel) {
        self._document = document
        self.viewModel = viewModel
    }

    var body: some View {
        VStack {

            if let urlStr = document.info.documentURL, let u = parseUrlString(urlStr: urlStr) {
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
    }
}
