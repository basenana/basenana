//
//  EntryProperty.swift
//  basenana
//
//  Created by zww on 2024/5/5.
//

import SwiftData
import Foundation
import GRDB

struct EntryPropertyModel: Codable {
    var key: String
    var value : String
    var encoded: Bool
}
