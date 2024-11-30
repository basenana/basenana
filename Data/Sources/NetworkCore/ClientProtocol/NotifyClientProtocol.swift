//
//  NotifyClientProtocol.swift
//
//
//  Created by Hypo on 2024/9/15.
//

import Foundation


public protocol NotifyClientProtocol {
    func ListMessage(all: Bool) async throws -> [APINotification]
    func ReadMeesage(id: String) async throws
}
