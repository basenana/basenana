//
//  DocumentView.swift
//  basenana
//
//  Created by Hypo on 2024/3/2.
//

import Foundation
import SwiftUI


struct DocumentView: View {
    @State private var selectedItem: DocumentModel?
    @State private var docs: [DocumentModel] = []
    @State var isDrawerOpen: Bool = false
    @EnvironmentObject private var docService: DocumentService
    
    var body: some View {
        NavigationView{
            List(docs, id: \.self, selection: $selectedItem) { document in
                NavigationLink {
                    GeometryReader { geometry in
                        ZStack(alignment: .bottomTrailing) {
                            HStack{
                                
                                Rectangle()
                                    .fill(Color.white)
                                    .overlay(
                                        HTMLStringView(htmlContent: selectedItem?.content ?? "")
                                    )
                                    .frame(minWidth: 0,  maxWidth: .infinity)
                                
                                
                                if isDrawerOpen{
                                    
                                    DialogueView(isDrawerOpen: $isDrawerOpen)
                                }
                            }
                            .overlay(
                                Button(action: {
                                    withAnimation(.easeInOut) {
                                        isDrawerOpen.toggle()
                                    }
                                }, label: {
                                        Image(systemName: isDrawerOpen ? "xmark.circle" : "ellipsis.message")
                                            .resizable()
                                            .foregroundColor(.blue)
                                            .frame(width: 25, height: 25)
                                            .offset(x: -5, y: 5)
                                    
                                })
                                .buttonStyle(PlainButtonStyle())
                                
                                ,alignment: .topTrailing
                            )
                            
                        }
                        .frame(width: geometry.size.width, height: geometry.size.height)
                        .layoutPriority(1)
                    }
                    
                } label: {
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

