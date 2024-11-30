//
//  InboxClient.swift
//
//
//  Created by Hypo on 2024/9/16.
//

import Foundation
import GRPC
import Entities
import NetworkCore


@available(macOS 11.0, *)
public class InboxClient: InboxClientProtocol {
    
    var client: Api_V1_InboxAsyncClientProtocol
    
    public init(clientSet: ClientSet) {
        self.client = clientSet.inbox
    }
    
    public func QuickInbox(_ f: Entities.QuickInbox) async throws {
        var req = Api_V1_QuickInboxRequest()
        
        switch f.sourceType {
        case .Url:
            req.sourceType = .urlSource
            req.url = f.url
            req.clutterFree = true
        case .Raw:
            req.sourceType = .urlSource // TODO: support raw source
            req.data = f.data!
        }
        
        req.filename = f.filename
        switch f.fileType {
        case .Bookmark:
            req.fileType = .bookmarkFile
        case .Html:
            req.fileType = .htmlFile
        case .Webarchive:
            req.fileType = .webArchiveFile
        }
        
        do {
            let _ = try await client.quickInbox(req, callOptions: defaultCallOptions)
        } catch let error as GRPCStatusTransformable where error.makeGRPCStatus().code == .cancelled {
            throw RepositoryError.canceled
        } catch {
            throw error
        }
    }
    
}
