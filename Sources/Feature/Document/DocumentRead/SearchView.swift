//
//  Search.swift
//  Document
//
//  Created by Hypo on 2024/12/11.
//
import SwiftUI
import Domain
import Domain
import SwiftUIMasonry

public struct SearchView: View{
    @State var search: String
    @State var viewModel: SearchViewModel

    public init(search: String, viewModel: SearchViewModel) {
        self.search = search
        self.viewModel = viewModel
    }

    public var body: some View {
        VStack{
            Text("Search not implemented yet")
                .foregroundColor(.secondary)
            Spacer()
        }
        .frame(minWidth: 300)
        .toolbar(removing: .sidebarToggle)
    }
}

