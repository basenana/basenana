//
//  AutoRead.swift
//  Document
//
//  Created by Hypo on 2024/12/7.
//

import Foundation


class AppearedDocument {
    var section: String?
    var uri: String
    var appearedAt: Date

    init(uri: String) {
        self.uri = uri
        self.appearedAt = Date()
    }

    init(document: DocumentItem) {
        self.section = document.sectionName
        self.uri = document.uri
        self.appearedAt = Date()
    }
}
