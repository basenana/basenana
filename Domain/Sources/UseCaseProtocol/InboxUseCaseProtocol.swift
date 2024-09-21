//
//  InboxUseCaseProtocol.swift
//  
//
//  Created by Hypo on 2024/9/14.
//

import Foundation
import Entities


public protocol InboxUseCaseProtocol {
    func quickInbox(url: String, fileName: String, fileType: FileType) throws
}
