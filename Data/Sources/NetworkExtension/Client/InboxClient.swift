//
//  InboxClient.swift
//
//
//  Created by Hypo on 2024/9/16.
//

import Foundation
import Entities
import NetworkCore


public class InboxClient: InboxClientProtocol {
    
    var client: Api_V1_InboxClientProtocol
    
    init(client: Api_V1_InboxClientProtocol) {
        self.client = client
    }
    
    public func QuickInbox(_ f: Entities.QuickInbox) throws {
        var req = Api_V1_QuickInboxRequest()
        
        switch f.sourceType {
        case .Url:
            req.sourceType = .urlSource
            req.url = f.url
        case .Raw:
            req.sourceType = .urlSource // TODO: support raw source
            req.data = f.data
        }
        
        switch f.fileType {
        case .Bookmark:
            req.fileType = .bookmarkFile
        case .Html:
            req.fileType = .htmlFile
        case .Webarchive:
            req.fileType = .webArchiveFile
        }
        
        let _ = try client.quickInbox(req, callOptions: defaultCallOptions).response.wait()
    }
    
}
