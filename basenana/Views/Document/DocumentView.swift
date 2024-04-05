//
//  DocumentView.swift
//  basenana
//
//  Created by Hypo on 2024/3/2.
//

import Foundation
import SwiftUI
import SwiftData


struct DocumentView: View {
    @State private var selectedItem: DocumentModel? = nil
    @State private var docs: [DocumentModel] = []
    @State var isDrawerOpen: Bool = false
    @State private var splitViewRatio: CGFloat = 0.5
    
    @EnvironmentObject private var docService: DocumentService
    
    var body: some View {
        NavigationView{
            List(docs, id: \.self, selection: $selectedItem) { document in
                NavigationLink {
                    GeometryReader { geometry in
                        ZStack(alignment: .bottomTrailing) {
                            HStack{
                                
                                HSplitView(){
                                    
                                    // document body
                                    Rectangle()
                                        .fill(Color.white)
                                        .overlay(
                                            HTMLStringView(htmlContent: selectedItem?.content ?? "")
                                        )
                                        .frame(minWidth: 200,  maxWidth: .infinity)
                                        .layoutPriority(1)
                                    
                                    if isDrawerOpen{
                                        // dialogue body
                                        DialogueView(isDrawerOpen: $isDrawerOpen)
                                            .frame(minWidth:200, idealWidth: 200, maxWidth: .infinity)
                                    }
                                    
                                }.layoutPriority(1)
                                
                            }
                            .overlay(
                                Group {
                                    if !isDrawerOpen {
                                        // button for open dialogue
                                        Button(action: {
                                            withAnimation(.easeInOut) {
                                                isDrawerOpen.toggle()
                                            }
                                        }, label: {
                                            Text("🍌")
                                                .font(.system(size: 30))
                                                .offset(x: -5, y: -5)
                                        })
                                        .buttonStyle(PlainButtonStyle())
                                        
                                    }
                                }
                                ,alignment: .bottomTrailing
                            )
                            
                        }
                        .frame(width: geometry.size.width, height: geometry.size.height)
                        .layoutPriority(1)
                    }
                    
                } label: {
                    // document items
                    DocumentItemView(doc: document)
                }
            }
            .frame(minWidth: 300, idealWidth: 300)
            .onAppear{
                docs = docService.listDocuments()
            }
        }
    }
}


#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: DocumentModel.self, configurations: config)
    
    container.mainContext.insert(DocumentModel(id: 100, oid: 100, name: "test document 1", parentEntryId: 1, source: "", keyWords: [], content: "Hello1", summary: "summary somethings", desync: false))
    container.mainContext.insert(DocumentModel(id: 101, oid: 100, name: "test document 1", parentEntryId: 1, source: "", keyWords: [], content: "Hello2", summary: "summary somethings", desync: false))
    
    return DocumentView().environmentObject(DocumentService(modelContext: container.mainContext))
}
