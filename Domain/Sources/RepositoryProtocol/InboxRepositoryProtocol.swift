//
//  InboxRepositoryProtocol.swift
//  
//
//  Created by Hypo on 2024/9/15.
//

import Foundation


protocol InboxRepositoryProtocol {
    func QuickInbox(_ :QuickInbox) throws -> EntryInfo
}

