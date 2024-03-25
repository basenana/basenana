//
//  DocumentService.swift
//  basenana
//
//  Created by zww on 2024/3/25.
//

import SwiftData
import Foundation
import SwiftUI
import Frostflake


class DocumentService: ObservableObject {
    
    private var modelContext: ModelContext
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    func listDocuments() -> [DocumentModel]{
        // TODO: filter by unread
        do {
            let rtn = try modelContext.fetch(FetchDescriptor<DocumentModel>())
            return rtn
        }catch{
            debugPrint("fetch documents failed")
            return []
        }
    }
    
    func saveDocument(name: String, content: String) {
        let newDoc = DocumentModel(id: genEntryID(), oid: genEntryID(), name: name, parentEntryId: Int64(1), source: "collect", content: content, desync: false)
        modelContext.insert(newDoc)
        do {
            try modelContext.save()
        } catch {
            debugPrint("insert document to inbox failed")
        }
        return
    }
    
    func reflush() {
        self.objectWillChange.send()
    }
}
