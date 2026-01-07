//
//  Search.swift
//  Document
//
//  Created by Hypo on 2024/12/11.
//
import SwiftUI
import AppState
import Entities
import SwiftUIMasonry

public struct SearchView: View{
    @State var search: String
    @State var viewModel: SearchViewModel
    @State var documents = [DocumentSearchItem]()
    
    public init(search: String, viewModel: SearchViewModel) {
        self.search = search
        self.viewModel = viewModel
    }
    
    public var body: some View {
        VStack{
//            TextField("Search...", text: $search
//                      onEditingChanged: { isEditing in
//                               isSearching = true
//                               updateSearchResults()
//                           }
//            )
//                           .textFieldStyle(RoundedBorderTextFieldStyle())
//                           .padding()
                           
            List() {
                ForEach(documents){ document in
                    NavigationLink(value: document) {
                        VStack{
                            SearchItemView(doc: document, searchModel: self.viewModel)
                        }
                    }
                }
                if viewModel.hasMore {
                    SearchLoadingView()
                }
            }
            .frame(minWidth: 300)
            .toolbar(removing: .sidebarToggle)
        }
        .onReceive(NotificationCenter.default.publisher(for: .loadMoreDocuments)) { _ in
            Task {
                documents = await viewModel.listNextPage()
            }
        }
        .task({
            await viewModel.doSearch(search: search)
        })
    }
}

struct SearchLoadingView: View {
    var body: some View {
        HStack(alignment: .center){
            Spacer()
            Text("☁️Loading ...")
                .padding(.vertical)
                .onAppear{
                    NotificationCenter.default.post(name: .loadMoreDocuments, object: nil)
                }
            Spacer()
        }
    }
}

