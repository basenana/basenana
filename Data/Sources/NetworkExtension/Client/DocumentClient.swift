//
//  DocumentClient.swift
//
//
//  Created by Hypo on 2024/9/16.
//

import Foundation
import Entities
import NetworkCore


@available(macOS 11.0, *)
public class DocumentClient: DocumentClientProtocol {
    
    var client: Api_V1_DocumentClientProtocol
    
    public init(clientSet: ClientSet) {
        self.client = clientSet.document
    }
    
    public func ListDocuments(filter: DocumentFilter) throws -> [APIDocumentInfo] {
        var req = Api_V1_ListDocumentsRequest()
        
        if filter.all != nil && filter.all! {
            req.listAll = true
        }
        
        if filter.parent != nil {
            req.parentID = filter.parent!
        }
        
        if filter.source != nil {
            req.filter.source = filter.source!
        }
        
        if filter.marked != nil {
            req.filter.marked = filter.marked!
        }
        
        if filter.unread != nil {
            req.filter.unread = filter.unread!
        }
        
        if filter.page != nil {
            var p = Api_V1_Pagination()
            p.page = filter.page!.page
            p.pageSize = filter.page!.pageSize
            req.pagination = p
        }
        
        switch filter.order {
        case nil: break
        case .name:
            req.order = .name
        case .source:
            req.order = .source
        case .marked:
            req.order = .marked
        case .unread:
            req.order = .unread
        case .createdAt:
            req.order = .createdAt
        }
        
        if filter.orderDesc != nil {
            req.orderDesc = filter.orderDesc!
        }
        
        let resp = try client.listDocuments(req, callOptions: defaultCallOptions).response.wait()
        var result: [APIDocumentInfo] = []
        for d in resp.documents {
            result.append(d.toDocuement())
        }
        return result
    }
    
    public func GetDocumentDetail(id: Entities.DocumentID) throws -> APIDocumentDetail {
        var req = Api_V1_GetDocumentDetailRequest()
        if id.documentID > 0 {
            req.documentID = id.documentID
        } else if id.entryID > 0 {
            req.entryID = id.entryID
        } else {
            throw RepositoryError.invalidResourceID
        }
        
        let resp = try client.getDocumentDetail(req, callOptions: defaultCallOptions).response.wait()
        
        return resp.document.toDocuement()
    }
    
    public func UpdateDocument(doc: Entities.DocumentUpdate) throws {
        var req = Api_V1_UpdateDocumentRequest()
        
        req.document.id = doc.docId
        if let unread = doc.unread {
            req.setMark = unread ? Api_V1_UpdateDocumentRequest.DocumentMark.unread:Api_V1_UpdateDocumentRequest.DocumentMark.read
        }
        if let mark = doc.marked {
            req.setMark = mark ? Api_V1_UpdateDocumentRequest.DocumentMark.marked:Api_V1_UpdateDocumentRequest.DocumentMark.unmarked
        }
        let _ = try client.updateDocument(req, callOptions: defaultCallOptions).response.wait()
    }
    
}
