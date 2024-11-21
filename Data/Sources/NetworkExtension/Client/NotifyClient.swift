//
//  NotifyClient.swift
//
//
//  Created by Hypo on 2024/9/17.
//

import Foundation
import Entities
import NetworkCore


@available(macOS 11.0, *)
public class NotifyClient: NotifyClientProtocol {
    
    var client: Api_V1_NotifyClientProtocol
    
    public init(clientSet: ClientSet) {
        self.client = clientSet.notify
    }
    
    public func ListMessage(all: Bool) throws -> [NetworkCore.APINotification] {
        throw RepositoryError.unimplement
    }
    
    public func ReadMeesage(id: String) throws {
        throw RepositoryError.unimplement
    }
    
    
}
