//
//  Item.swift
//  basenana
//
//  Created by Hypo on 2024/2/27.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
