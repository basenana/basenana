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
    @State var selection: DocumentSearchItem?
    @State var isHovering: [DocumentSearchItem: Bool] = [:]

    public init(search: String, viewModel: SearchViewModel) {
        self.search = search
        self.viewModel = viewModel
    }
    
    public var body: some View {
        VStack{
            List(selection: $selection) {
                if self.viewModel.documents.isEmpty && !viewModel.hasMore{
                    NoRecordView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                    
                ForEach(self.viewModel.documents){ document in
                    NavigationLink(value: document) {
                        VStack{
                            SearchItemView(
                                doc: document,
                                searchModel: self.viewModel,
                                isHovering: Binding(
                                    get: { self.isHovering[document, default: false] },
                                    set: { value in self.isHovering[document] = value }
                                )
                            )
                        }
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(isHovering[document] ?? false ? Color.gray.opacity(0.2) : Color.clear)
                        )
                        .onHover { hovering in
                            isHovering[document] = hovering
                        }
                    }
                }
                if viewModel.hasMore {
                    LoadingView()
                }
            }
            .frame(minWidth: 300)
            .toolbar(removing: .sidebarToggle)
        }
        .onReceive(NotificationCenter.default.publisher(for: .loadMoreDocuments)) { _ in
            Task {
                await viewModel.loadNextPage()
            }
        }
        .task({
            await viewModel.doSearch(search: search)
        })
    }
}

struct LoadingView: View {
    var body: some View {
        HStack(alignment: .center){
            Spacer()
            Text("☁️ Loading...")
                .padding(.vertical)
                .onAppear{
                    NotificationCenter.default.post(name: .loadMoreDocuments, object: nil)
                }
            Spacer()
        }
    }
}

struct NoRecordView: View {
    var body: some View {
        VStackLayout(alignment: .leading) {
            Spacer()
            Text("😯 No Results Found.")
                .font(.system(size: 14, weight: .thin, design: .monospaced))
                .padding(.vertical)
            Spacer()
        }
    }
}


#if DEBUG

import AppState
import DomainTestHelpers

struct SearchViewPreview: View {
    @State private var doc: DocumentInfo? = nil
    @State private var uc = MockDocumentUseCase()
    
    var body: some View {
        VStack{
            SearchView(search: "hello", viewModel: SearchViewModel(store: StateStore.shared, usecase: uc) )
        }
        .task {
            do {
                let docs = try await uc.searchDocuments(search: "a", page: 1, pageSize: 1).first!
            } catch {
                print("Failed to load entry details: \(error)")
            }
        }
    }
}

#Preview{
    SearchViewPreview()
}

#endif

