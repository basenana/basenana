//
//  SyncModel.swift
//  basenana
//
//  Created by Hypo on 2024/4/15.
//

import Foundation
import SwiftData

@Model
class ConfigModel: Identifiable {
    @Attribute(.unique) var id: String
    var value: String
    
    init(id: String, value: String) {
        self.id = id
        self.value = value
    }
}
