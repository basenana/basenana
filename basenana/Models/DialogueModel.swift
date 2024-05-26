//
//  MessageModel.swift
//  basenana
//
//  Created by zww on 2024/4/7.
//

import Foundation
import SwiftData
import GRDB

struct RoomModel {
    var id: Int64?
    var namespace: String?
    var oid: Int64
    var title: String?
    var prompt: String?
    
    var createdAt: Date
    
    var messages: [RoomMessageModel]
}

struct RoomMessageModel: Codable, Identifiable {
    var id: Int64?
    var namespace: String?
    var roomid: Int64
    var sender: String
    var message: String
    
    var sendAt: Date
    var createdAt: Date
}
