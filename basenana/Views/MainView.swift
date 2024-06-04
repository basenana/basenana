//
//  MainView.swift
//  basenana
//
//  Created by Hypo on 2024/3/24.
//

import SwiftUI


struct MainView: View{
    
    @State private var search: String = ""
    @State private var searchEntry: Int64? = nil
    
    init(){
        setupLogging()
        AuthClient().reflushToken()
    }
    
    var body: some View {
        // fixme
        if !authStatus.hasAccessToken {
            SettingsView()
        }else {
            NavigationSplitView {
                SidebarView(searchEntry: $searchEntry)
                    .frame(minWidth: 180,idealWidth: 200)
            }detail: {
                if searchEntry != nil{
                    DocumentDetailView(entryId: searchEntry!)
                }
            }
            .searchable(text: $search) {
                let docs = documentService.searchDocument(search: search)
                ForEach(docs, id: \.id) { doc in
                    Button {
                        searchEntry = doc.oid
                    } label: {
                        Label(doc.name, systemImage: "doc.text")
                    }
                }
            }
            .onChange(of: search) {
                if search.isEmpty {
                    searchEntry = nil
                }
            }
        }
    }
}
