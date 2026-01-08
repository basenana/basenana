//
//  NotificationRepositoryProtocol.swift
//  
//
//  Created by Hypo on 2024/9/15.
//

import Foundation



public protocol NotificationRepositoryProtocol {
    func ListMessage(all: Bool) async throws -> [NotificationMessage]
    func ReadMeesage(id: String) async throws
}


