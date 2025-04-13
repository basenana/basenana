//
//  DocumentSection.swift
//  Document
//
//  Created by Hypo on 2024/11/23.
//

import SwiftUI
import Foundation
import Entities



@Observable
class DocumentSection: Identifiable {
    var id: String
    var documents: [DocumentSearchItem]
    
    init(id: String, documents: [DocumentSearchItem]) {
        self.id = id
        self.documents = documents
    }
}

@Observable
class DocumentItem: Identifiable, Hashable, Equatable {
    var id: Int64 {
        get {
            return info.id
        }
    }
    
    var properties: [EntryProperty] {
        get {
            return info.properties
        }
    }
    
    var parent: EntryInfo {
        get {
            return info.parent
        }
    }
    
    var info: DocumentInfo
    var readable: Bool = false
    
    init(info: DocumentInfo) {
        self.info = info
        self.readable = false
    }
    
    init(info: DocumentInfo, readable: Bool) {
        self.info = info
        self.readable = readable
    }
    
    var sectionName: String {
        if Calendar.current.isDateInToday(info.createdAt){
            return "TODAY"
        }
        if Calendar.current.isDateInYesterday(info.createdAt){
            return "YESTERDAY"
        }
        
        return dateFormatter.string(from: info.createdAt)
    }
    
    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        formatter.dateFormat = "yyyy/MM/dd"
        return formatter
    }()
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: DocumentItem, rhs: DocumentItem) -> Bool {
        return lhs.id == rhs.id
    }
    
}
struct DocumentSearchItem: Identifiable, Hashable, Equatable {
    var id: Int64 {
        get {
            info.id
        }
    }
    
    var searchContent: [String] {
        get {
            info.searchContent
        }
    }
    
    var properties: [EntryProperty] {
        get {
            return info.properties
        }
    }
    
    var parent: EntryInfo {
        get {
            return info.parent
        }
    }
    var headerImage: String {
        get {
            return info.headerImage
        }
    }

    var info: DocumentInfo
    
    init(info: DocumentInfo) {
        self.info = info
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(info.id)
    }
    
    static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.id == rhs.id
    }
}
