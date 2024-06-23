//
//  DocumentDetailView.swift
//  basenana
//
//  Created by zww on 2024/5/8.
//

import Foundation
import SwiftUI

struct DocumentDetailView: View {
    var document: DocumentInfoModel
    
    @State private var detail: DocumentDetailModel? = nil
    @State private var openFriday: Bool = false
    @Environment(\.sendAlert) var sendAlert
    
    var body: some View{
        
        GeometryReader { geometry in
            ZStack(alignment: .bottomTrailing) {
                if let detailDocument = detail {
                    DocumentFridayView(document: detailDocument, openFriday: $openFriday)
                    .overlay(
                        Group {
                            if !openFriday {
                                FridayButton(openFriday: $openFriday)
                            }
                        }
                        ,alignment: .bottomTrailing
                    )
                }
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
            .layoutPriority(1)
            .task {
                do {
                    let clientSet = try clientFactory.makeClient()
                    var request = Api_V1_GetDocumentDetailRequest()
                    request.documentID = document.id
                    
                    let call = clientSet.document.getDocumentDetail(request, callOptions: defaultCallOptions)
                    let response = try await call.response.get()
                    self.detail = response.document.toDocuement()
                } catch {
                    sendAlert("get docuemnt \(document.id) detail failed \(error)")
                }
            }
        }
    }
}

struct DocumentFridayView: View {
    var document: DocumentDetailModel
    @Binding var openFriday: Bool
    
    var body: some View{
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
                
                if openFriday{
                    // dialogue body
                    DialogueView(openFriday: $openFriday, entryId: document.oid)
                        .id("\(document.oid)/room")
                        .frame(minWidth:200, idealWidth: 200, maxWidth: .infinity)
                }
                
            }.layoutPriority(1)
        }
    }
}


struct FridayButton: View {
    @Binding var openFriday: Bool
    
    var body: some View {
        Button(action: {
            withAnimation(.easeInOut) {
                openFriday.toggle()
            }
        }, label: {
            Text("🍌")
                .font(.system(size: 30))
        })
        .offset(x: -20, y: -10)
        .buttonStyle(PlainButtonStyle())
    }
}
