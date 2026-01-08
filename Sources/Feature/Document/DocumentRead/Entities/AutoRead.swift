//
//  AutoRead.swift
//  Document
//
//  Created by Hypo on 2024/12/7.
//

import Foundation


class AppearedDocument {
    var section: String
    var documentID: Int64
    var appearedAt: Date
    
    init(document: DocumentItem) {
        self.section = document.sectionName
        self.documentID = document.id
        self.appearedAt = Date()
    }
}
