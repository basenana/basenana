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
    var documents: [DocumentItem]
    
    init(id: String, documents: [DocumentItem]) {
        self.id = id
        self.documents = documents
    }
}

struct DocumentItem: Identifiable {
    var id: Int64 {
        get {
            return info.id
        }
    }
    var info: DocumentInfo
    var keepLowProfile: Bool = false
    
    init(info: DocumentInfo) {
        self.info = info
        self.keepLowProfile = false
    }

    init(info: DocumentInfo, keepLowProfile: Bool) {
        self.info = info
        self.keepLowProfile = keepLowProfile
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
}
