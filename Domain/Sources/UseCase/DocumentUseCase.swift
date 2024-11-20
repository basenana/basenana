//
//  DocumentUseCase.swift
//  Domain
//
//  Created by Hypo on 2024/9/18.
//

import Entities
import RepositoryProtocol
import UseCaseProtocol

public class DocumentUseCase: DocumentUseCaseProtocol {
    
    private var docRepo: DocumentRepositoryProtocol
    private var entryRepo: EntryRepositoryProtocol

    public init(docRepo: DocumentRepositoryProtocol, entryRepo: EntryRepositoryProtocol) {
        self.docRepo = docRepo
        self.entryRepo = entryRepo
    }
    
    public func listUnreadDocuments(page: Int, pageSize: Int) throws -> [any Entities.DocumentInfo] {
        var filter = DocumentFilter()
        filter.page = Pagination()
        filter.page!.page = Int64(page)
        filter.page!.pageSize = Int64(pageSize)
        filter.unread = true
        filter.order = .createdAt
        filter.orderDesc = true
        return try docRepo.ListDocuments(filter: filter)
    }
    
    public func listMarkedDocuments(page: Int, pageSize: Int) throws -> [any Entities.DocumentInfo] {
        var filter = DocumentFilter()
        filter.page = Pagination()
        filter.page!.page = Int64(page)
        filter.page!.pageSize = Int64(pageSize)
        filter.marked = true
        filter.order = .createdAt
        filter.orderDesc = true
        return try docRepo.ListDocuments(filter: filter)
    }

    public func getDocumentDetails(entry: Int64) throws -> any Entities.DocumentDetail {
        return try docRepo.GetDocumentDetail(id: DocumentID(entryID: entry))
    }
    
    public func getDocumentDetails(document: Int64) throws -> any Entities.DocumentDetail {
        return try docRepo.GetDocumentDetail(id: DocumentID(documentID: document))
    }
    
    public func getDocumentProperty(entry: Int64, key: String) throws -> Entities.EntryProperty? {
        let entry = try entryRepo.GetEntryDetail(entry: entry)
        for p in entry.properties {
            if p.key == key {
                return p
            }
        }
        return nil
    }

    public func getDocumentProperty(document: Int64, key: String) throws -> Entities.EntryProperty? {
        let doc = try getDocumentDetails(document: document)
        return try getDocumentProperty(entry: doc.oid, key: key)
    }

    public func setDocumentMarkState(document: Int64, ismark: Bool) throws {
        var docUpdate = DocumentUpdate(docId: document)
        docUpdate.marked = ismark
        return try docRepo.UpdateDocument(doc: docUpdate)
    }
    
    public func setDocumentReadState(document: Int64, unread: Bool) throws {
        var docUpdate = DocumentUpdate(docId: document)
        docUpdate.unread = unread
        return try docRepo.UpdateDocument(doc: docUpdate)
    }
}
