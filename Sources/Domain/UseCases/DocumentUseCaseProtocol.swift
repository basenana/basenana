//
//  DocumentUseCaseProtocol.swift
//
//
//  Created by Hypo on 2024/9/13.
//

import Foundation



public protocol DocumentUseCaseProtocol {
    func listUnreadDocuments(page: Int, pageSize: Int) async throws -> [DocumentInfo]
    func listMarkedDocuments(page: Int, pageSize: Int) async throws -> [DocumentInfo]
    func searchDocuments(search: String,page: Int, pageSize: Int) async throws -> [DocumentInfo]
    
    func getDocumentDetails(entry: Int64) async throws -> DocumentDetail
    func getDocumentDetails(document: Int64) async throws -> DocumentDetail
    
    func getDocumentEntry(entry: Int64) async throws ->  EntryDetail?
    func getDocumentEntry(document: Int64) async throws ->  EntryDetail?
    
    func setDocumentMarkState(document: Int64, ismark: Bool) async throws
    func setDocumentReadState(document: Int64, unread: Bool) async throws
}
