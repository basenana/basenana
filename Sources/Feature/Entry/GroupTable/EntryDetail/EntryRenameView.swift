//
//  EntryRenameView.swift
//  Entry
//
//  Created by Hypo on 2024/11/28.
//
import SwiftUI
import FeedKit
import Domain


struct EntryRenameView: View {
    @State private var entryUri: String
    @State private var entry: EntryDetail?
    @State private var viewModel: EntryDetailViewModel

    @Binding private var showRenameView: Bool

    init(entryUri: String, viewModel: EntryDetailViewModel, showRenameView: Binding<Bool>) {
        self.entryUri = entryUri
        self.viewModel = viewModel
        self._showRenameView = showRenameView
    }

    // Common
    @State private var parentName: String = ""
    @State private var entryName: String = ""

    var body: some View{
        Form{
            TextField("Name", text: $entryName)
                .textFieldStyle(.roundedBorder)
                .padding(.vertical, 5)


            HStack {
                if viewModel.errorMessage != ""{
                    Text("\(viewModel.errorMessage)")
                        .foregroundStyle(.red)
                        .padding(.vertical, 5)
                        .padding(.trailing, 20)
                }
                Button {
                    if let en = entry {
                        Task {
                            if await viewModel.renameEntry(entry: en, newName: entryName){
                                showRenameView.toggle()
                            }
                        }
                    }
                } label: {
                    Text("Rename")
                        .font(.body)
                        .padding(6)
                        .foregroundColor(.white)
                        .background(Color.blue)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }
                .buttonStyle(PlainButtonStyle())
            }
            .frame(maxWidth: .infinity, alignment: .trailing)
            .padding(.top, 10)
        }
        .padding(50)
        .frame(minWidth: 500)
        .task{
            viewModel.errorMessage = ""
            entry = await viewModel.describeEntry(uri: entryUri)
            if let en = entry {
                entryName = en.name
            }
        }
    }
}
