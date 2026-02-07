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
    @State private var viewModel: GroupTableViewModel

    @State private var targetDetail: EntryDetail? = nil

    public init(viewModel: GroupTableViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {

        EmptyView()
            .onChange(of: viewModel.selection) {
                guard viewModel.selectedEntries.count == 1,
                      let target = viewModel.selectedEntries.first else {
                    targetDetail = nil
                    return
                }
                Task {
                    targetDetail = await viewModel.describeEntry(uri: target.uri)
                }
            }
    }
}
