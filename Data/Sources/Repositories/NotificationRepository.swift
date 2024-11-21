//
//  NotificationRepository.swift
//  
//
//  Created by Hypo on 2024/9/15.
//

import Foundation
import Entities
import NetworkCore
import RepositoryProtocol


public class NotificationRepository: NotificationRepositoryProtocol {
    
    private var core: NotifyClientProtocol
    
    init(core: NotifyClientProtocol) {
        self.core = core
    }
    
    public func ListMessage(all: Bool) throws -> [any Entities.NotificationMessage] {
        return try core.ListMessage(all: all)
    }
    
    public func ReadMeesage(id: String) throws {
        return try core.ReadMeesage(id: id)
    }
}
