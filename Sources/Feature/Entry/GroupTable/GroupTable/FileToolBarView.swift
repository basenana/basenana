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
            .onChange(of: viewModel.selection){
                let selectedEntries = viewModel.selectedEntries
                if selectedEntries.count == 1 {
                    if let target = selectedEntries.first {
                        Task {
                            targetDetail = await viewModel.describeEntry(uri: target.uri)

                            // parse url
                            if let pro = getEntryProperty(keys: [Property.WebPageURL, Property.WebSiteURL]) {
                                if let u = URL(string: pro.value) {
                                    targetURL = u
                                    return
                                }
                            }
                        }
                        targetURL = nil
                    }
                }
            }
    }

    func getEntryProperty(keys: [String]) -> EntryProperty?{
        guard targetDetail != nil else {
            return nil
        }
        for k in keys {
            for p in targetDetail!.properties {
                if p.key == k {
                    return p
                }
            }
        }
        return nil
    }
}
