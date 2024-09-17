//
//  InboxRepository.swift
//  
//
//  Created by Hypo on 2024/9/15.
//

import Foundation
import Entities
import NetworkCore
import RepositoryProtocol


public class InboxRepository: InboxRepositoryProtocol {
    
    private var core: InboxClientProtocol
    
    init(core: InboxClientProtocol) {
        self.core = core
    }
    
    public func QuickInbox(_ f: Entities.QuickInbox) throws {
        return try core.QuickInbox(f)
    }
}
