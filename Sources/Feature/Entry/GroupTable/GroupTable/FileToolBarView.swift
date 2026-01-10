//
//  FileToolBarView.swift
//  Entry
//
//  Created by Hypo on 2024/11/28.
//
import Foundation
import SwiftUI
import Domain
import Domain
import Styleguide


struct FileToolBarView: View {
    @State private var groupTree = GroupTree.shared
    @State private var viewModel: GroupTableViewModel

    @State private var targetDetail: EntryDetail? = nil
    @State private var targetURL: URL? = nil

    public init(viewModel: GroupTableViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        // web file
        if let u = targetURL {
            Button(action: {
                openUrlInBrowser(url: u)
            }, label: {
                Image(systemName: "safari")
            })

            Button(action: {
                copyToClipBoard(content: "\(u.absoluteString)")
                sentAlert("Link Copied")
            }, label: {
                Image(systemName: "link")
            })
        }

        EmptyView()
            .onChange(of: viewModel.selection) {
                guard viewModel.selectedEntries.count == 1,
                      let target = viewModel.selectedEntries.first else {
                    targetDetail = nil
                    targetURL = nil
                    return
                }
                Task {
                    targetDetail = await viewModel.describeEntry(uri: target.uri)
                    targetURL = targetDetail?.documentURL.flatMap { URL(string: $0) }
                }
            }
    }
}
