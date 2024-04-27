//
//  EntryViewModel.swift
//  basenana
//
//  Created by Hypo on 2024/4/27.
//

import SwiftUI
import Foundation
import UniformTypeIdentifiers

struct EntryViewModel: Codable {
    var id: Int64
    var isGroup: Bool
    
    init(id: Int64, isGroup: Bool) {
        self.id = id
        self.isGroup = isGroup
    }
}
