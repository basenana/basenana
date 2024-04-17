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
                                        DialogueView(isDrawerOpen: $isDrawerOpen, docId: document.id!)
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
                docs = documentService.listDocuments()
            }
        }
    }
}


#Preview {
    return DocumentView()
}
