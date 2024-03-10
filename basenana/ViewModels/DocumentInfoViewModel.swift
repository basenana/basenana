//
//  DocumentViewModel.swift
//  basenana
//
//  Created by Hypo on 2024/2/29.
//

import Foundation

class DocumentInfoViewModel: ObservableObject, Hashable {
    @Published var id: Int64
    @Published var oid: Int64
    @Published var name: String
    @Published var parentEntryId: Int64
    @Published var content: String
    @Published var createdAt: Date
    @Published var changedAt: Date
    
    init(doc: DocumentInfo) {
        self.id = doc.id
        self.oid = doc.oid
        self.name = doc.name
        self.parentEntryId = doc.parentEntryId
        self.content = doc.content
        self.createdAt = doc.createdAt
        self.changedAt = doc.changedAt
    }
    
    static func == (lhs: DocumentInfoViewModel, rhs: DocumentInfoViewModel) -> Bool {
        return lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

class DocumentDetailViewModel: ObservableObject {
    @Published var id: Int64
    @Published var oid: Int64
    @Published var name: String
    @Published var parentEntryId: Int64
    @Published var source: String
    @Published var keyWords : [String]?
    @Published var content: String
    @Published var summary: String?
    @Published var desync: Bool
    @Published var createdAt: Date
    @Published var changedAt: Date
    @Published var isSelected: Bool
    
    
    init(doc: DocumentDetail) {
        self.id = doc.id
        self.oid = doc.oid
        self.name = doc.name
        self.parentEntryId = doc.parentEntryId
        self.source = doc.source
        self.keyWords = doc.keyWords
        self.content = doc.content
        self.summary = doc.summary
        self.desync = doc.desync
        self.createdAt = doc.createdAt
        self.changedAt = doc.changedAt
        self.isSelected = false
    }
    
}

