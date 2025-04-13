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
    
    public func listUnreadDocuments(page: Int, pageSize: Int) async throws -> [any Entities.DocumentInfo] {
        var filter = DocumentFilter()
        filter.page = Pagination()
        filter.page!.page = Int64(page)
        filter.page!.pageSize = Int64(pageSize)
        filter.unread = true
        filter.order = .createdAt
        filter.orderDesc = true
        do {
            return try await docRepo.ListDocuments(filter: filter)
        } catch RepositoryError.canceled {
            throw UseCaseError.canceled
        }
    }
    
    public func listMarkedDocuments(page: Int, pageSize: Int) async throws -> [any Entities.DocumentInfo] {
        var filter = DocumentFilter()
        filter.page = Pagination()
        filter.page!.page = Int64(page)
        filter.page!.pageSize = Int64(pageSize)
        filter.marked = true
        filter.order = .createdAt
        filter.orderDesc = true
        do {
            return try await docRepo.ListDocuments(filter: filter)
        } catch RepositoryError.canceled {
            throw UseCaseError.canceled
        }
    }
    
    public func searchDocuments(search: String, page: Int, pageSize: Int) async throws -> [any Entities.DocumentInfo] {
        var filter = DocumentFilter()
        filter.page = Pagination()
        filter.page!.page = Int64(page)
        filter.page!.pageSize = Int64(pageSize)
        filter.search = search
        filter.order = .createdAt
        filter.orderDesc = true
        do {
            return try await docRepo.ListDocuments(filter: filter)
        } catch RepositoryError.canceled {
            throw UseCaseError.canceled
        }
    }
    
    public func getDocumentDetails(entry: Int64) async throws -> any Entities.DocumentDetail {
        do {
            return try await docRepo.GetDocumentDetail(id: DocumentID(entryID: entry))
        } catch RepositoryError.canceled {
            throw UseCaseError.canceled
        }
    }
    
    public func getDocumentDetails(document: Int64) async throws -> any Entities.DocumentDetail {
        do {
            return try await docRepo.GetDocumentDetail(id: DocumentID(documentID: document))
        } catch RepositoryError.canceled {
            throw UseCaseError.canceled
        }
    }
    
    public func getDocumentEntry(entry: Int64) async throws -> Entities.EntryDetail? {
        do {
            return try await entryRepo.GetEntryDetail(entry: entry)
        } catch RepositoryError.canceled {
            return nil
        }
    }
    
    public func getDocumentEntry(document: Int64) async throws -> Entities.EntryDetail? {
        do {
            let doc = try await getDocumentDetails(document: document)
            return try await getDocumentEntry(entry: doc.oid)
        } catch RepositoryError.canceled {
            return nil
        }
    }
    
    public func setDocumentMarkState(document: Int64, ismark: Bool) async throws {
        do {
            var docUpdate = DocumentUpdate(docId: document)
            docUpdate.marked = ismark
            try await docRepo.UpdateDocument(doc: docUpdate)
        } catch RepositoryError.canceled {
            return
        }
    }
    
    public func setDocumentReadState(document: Int64, unread: Bool) async throws {
        do {
            var docUpdate = DocumentUpdate(docId: document)
            docUpdate.unread = unread
            try await docRepo.UpdateDocument(doc: docUpdate)
        } catch RepositoryError.canceled {
            return
        }
    }
}
