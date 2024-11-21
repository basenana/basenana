//
//  DocumentUseCaseProtocol.swift
//
//
//  Created by Hypo on 2024/9/13.
//

import Foundation
import Entities


public protocol DocumentUseCaseProtocol {
    func listUnreadDocuments(page: Int, pageSize: Int) throws -> [DocumentInfo]
    func listMarkedDocuments(page: Int, pageSize: Int) throws -> [DocumentInfo]
    
    func getDocumentDetails(entry: Int64) throws -> DocumentDetail
    func getDocumentDetails(document: Int64) throws -> DocumentDetail
    
    func getDocumentEntry(entry: Int64) throws -> Entities.EntryDetail?
    func getDocumentEntry(document: Int64) throws -> Entities.EntryDetail?
    
    func setDocumentMarkState(document: Int64, ismark: Bool) throws
    func setDocumentReadState(document: Int64, unread: Bool) throws
}
