//
//  Dialogue.swift
//
//
//  Created by Hypo on 2024/9/13.
//

import Foundation


protocol Room {
    var id: Int64 { get }
    var namespace: String { get }
    var oid: Int64 { get }
    var title: String { get }
    var prompt: String { get }
    
    var createdAt: Date { get }
    
    var messages: [RoomMessage] { get }
}

protocol RoomMessage {
    var id: Int64 { get }
    var namespace: String { get }
    var roomid: Int64 { get }
    var sender: String { get }
    var message: String { get }
    
    var sendAt: Date { get }
    var createdAt: Date { get }
}
