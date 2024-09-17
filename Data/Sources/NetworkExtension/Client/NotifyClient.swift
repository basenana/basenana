//
//  NotifyClient.swift
//
//
//  Created by Hypo on 2024/9/17.
//

import Foundation
import Entities
import NetworkCore


public class NotifyClient: NotifyClientProtocol {
    
    var client: Api_V1_NotifyClientProtocol
    
    init(client: Api_V1_NotifyClientProtocol) {
        self.client = client
    }
    
    public func ListMessage(all: Bool) throws -> [NetworkCore.APINotification] {
        throw RepositoryError.unimplement
    }
    
    public func ReadMeesage(id: String) throws {
        throw RepositoryError.unimplement
    }
    
    
}
