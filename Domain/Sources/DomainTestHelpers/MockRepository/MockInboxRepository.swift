//  MockInboxRepository.swift
//  Entry
//
//  Created by Hypo on 2024/9/22.
//

import SwiftUI
import Entities
import RepositoryProtocol


public class MockInboxRepository: InboxRepositoryProtocol {
    
    public static var shared = MockInboxRepository()
    
    init() { }
    
    public func QuickInbox(_: Entities.QuickInbox) throws {
        return
    }
    
}
