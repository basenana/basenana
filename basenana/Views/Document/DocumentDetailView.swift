//
//  DocumentDetailView.swift
//  basenana
//
//  Created by zww on 2024/5/8.
//

import Foundation
import SwiftUI

struct DocumentDetailView: View {
    @State var isDrawerOpen: Bool = false
    var entryId: Int64
    
    var doc: DocumentDetailModel? {
        get {
            do {
                return try service.getDocument(entryId: entryId)
            } catch {
                return nil
            }
        }
    }
    
    var body: some View{
        if let document = doc {
            
            GeometryReader { geometry in
                ZStack(alignment: .bottomTrailing) {
                    HStack{
                        
                        HSplitView(){
                            
                            // document body
                            Rectangle()
                                .fill(Color.white)
                                .overlay(
                                    HTMLStringView(htmlContent: document.content)
                                )
                                .frame(minWidth: 200,  maxWidth: .infinity)
                                .layoutPriority(1)
                            
                            if isDrawerOpen{
                                // dialogue body
                                DialogueView(docId: document.id, entryId: document.oid, isDrawerOpen: $isDrawerOpen)
                                    .id("\(document.oid)/room")
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
                                })
                                .offset(x: -20, y: -10)
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        ,alignment: .bottomTrailing
                    )
                    
                }
                .frame(width: geometry.size.width, height: geometry.size.height)
                .layoutPriority(1)
            }
        }
        
    }
}
