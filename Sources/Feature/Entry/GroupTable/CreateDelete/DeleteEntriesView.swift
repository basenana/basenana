//
//  DeleteEntriesView.swift
//  Entry
//
//  Created by Hypo on 2024/11/29.
//

import os
import SwiftUI
import FeedKit
import Domain


struct DeleteEntriesView: View {
    @State private var entryUris: [String]
    @State private var viewModel: CreateDeleteViewModel
    @Binding private var showDeleteView: Bool

    @State private var entries: [EntryRow] = []
    @State private var errorMsg: String = ""

    private static let logger = Logger(
            subsystem: Bundle.main.bundleIdentifier!,
            category: String(describing: DeleteEntriesView.self)
        )

    init(entryUris: [String], viewModel: CreateDeleteViewModel, showDeleteView: Binding<Bool>) {
        self.entryUris = entryUris
        self.viewModel = viewModel
        self._showDeleteView = showDeleteView
    }

    var body: some View{
        Form{

            VStack(alignment: .leading) {
                Text("You are deleting the following entries:")
                    .bold()
                    .padding(.bottom, 5)
                ForEach(entries) { en in
                    Text("\(en.name)")
                        .fontWeight(.light)
                        .padding(.horizontal, 5)
                        .padding(.vertical, 1)
                }
            }

            HStack {
                if errorMsg != ""{
                    Text("\(errorMsg)")
                        .foregroundStyle(.red)
                        .padding(.vertical, 5)
                        .padding(.trailing, 20)
                }
                Button {
                    Task {
                        await viewModel.deleteEntries(entries: entries.map({$0.info}))
                        showDeleteView.toggle()
                    }
                } label: {
                    Text("Delete")
                        .font(.body)
                        .padding(6)
                        .foregroundColor(.white)
                        .background(Color.red)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }
                .buttonStyle(PlainButtonStyle())
            }
            .frame(maxWidth: .infinity, alignment: .trailing)
            .padding(.top, 10)
        }
        .task{
            Self.logger.info("try to delete entries \(self.entryUris)")
            for entryUri in entryUris {
                if let detail = await viewModel.describeEntry(uri: entryUri) {
                    entries.append(EntryRow(info: detail.toInfo()!))
                }else{
                    errorMsg = "entry not found"
                    break
                }
            }
        }
        .padding(50)
        .frame(minWidth: 500)
    }
}

