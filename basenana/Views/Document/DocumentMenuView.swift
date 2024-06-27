//
//  DocumentMenuView.swift
//  basenana
//
//  Created by Hypo on 2024/6/22.
//

import SwiftUI
import Foundation

struct DocumentMenuView: View {
    @State var doc: DocumentInfoModel
    @State var property = PropertyViewModel()
    
    @Binding var readerViewModel: DocumentReaderViewModel
    @Environment(Store.self) private var store: Store
    @Environment(\.sendAlert) var sendAlert
    @Environment(\.openURL) var openURL
    
    var body: some View {
        VStack {
            Section{
                Button("Go To Group", action: {
                    store.dispatch(.gotoDestination(.groupListByID(groupID: doc.parentId)))
                })
            }
            
            Section{
                Button("Launch URL", action: {
                    if let pro = property.getProperty(k: PropertyWebPageURL){
                        if let pageUrl = URL(string: pro.value){
                            openURL.callAsFunction(pageUrl){ result in
                                log.info("open docuemnt url \(pro.value), resule: \(result)")
                            }
                        }
                    }else {
                        log.warning("can not get document \(doc.id) url")
                    }
                })
                Button("Copy URL", action: {
                    if let pro = property.getProperty(k: PropertyWebPageURL){
                        copyToClipBoard(textToCopy: pro.value)
                    }
                })
            }
            
            Section{
                Menu("Mark"){
                    DocumentMarkMenuView(doc: $doc, readerViewModel: $readerViewModel)
                }
            }
        }
        .task {
            do {
                try await property.initEntry(entryID: doc.oid)
            } catch {
                log.warning("fetch entry property failed \(error)")
            }
        }
    }
}
    

struct DocumentMarkMenuView: View {
    @Binding var doc: DocumentInfoModel
    @Binding var readerViewModel: DocumentReaderViewModel
    @Environment(Store.self) private var store: Store
    
    var body: some View {
        Button {
            withAnimation(.easeInOut) {
                var isRead = readerViewModel.readed.contains(doc.id)
                isRead.toggle()
                store.dispatch(.updateDocument(docUpdate: DocumentUpdate(docId: doc.id, unread: !isRead)))
                if isRead {
                    readerViewModel.readed.insert(doc.id)
                }else{
                    readerViewModel.readed.remove(doc.id)
                }
            }
        } label: {
            Text("Unread")
            if !readerViewModel.readed.contains(doc.id) {
                Image(systemName: "checkmark")
            }
        }
        Button {
            withAnimation(.easeInOut) {
                var isMark = readerViewModel.marked.contains(doc.id)
                isMark.toggle()
                store.dispatch(.updateDocument(docUpdate: DocumentUpdate(docId: doc.id, marked: isMark)))
                if isMark {
                    readerViewModel.marked.insert(doc.id)
                }else{
                    readerViewModel.marked.remove(doc.id)
                }
            }
        } label: {
            Text("Mark")
            if readerViewModel.marked.contains(doc.id) {
                Image(systemName: "checkmark")
            }
        }
    }
}
