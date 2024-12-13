//
//  DeleteEntriesView.swift
//  Entry
//
//  Created by Hypo on 2024/11/29.
//


import SwiftUI
import FeedKit
import Entities


struct DeleteEntriesView: View {
    @State private var entryIDs: [Int64]
    @State private var viewModel: CreateDeleteViewModel
    @Binding private var showDeleteView: Bool

    @State private var entries: [EntryRow] = []
    @State private var errorMsg: String = ""

    init(entryIDs: [Int64], viewModel: CreateDeleteViewModel, showDeleteView: Binding<Bool>) {
        self.entryIDs = entryIDs
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
            print("try to delete entries \(entryIDs)")
            for entryId in entryIDs {
                if let detail = await viewModel.describeEntry(entry: entryId) {
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


#if DEBUG

import AppState
import DomainTestHelpers


#Preview {
    DeleteEntriesView(
        entryIDs: [1011, 1012],
        viewModel: CreateDeleteViewModel(store: StateStore.shared, entryUsecase: MockEntryUseCase()),
        showDeleteView: .constant(true))
}

#endif

