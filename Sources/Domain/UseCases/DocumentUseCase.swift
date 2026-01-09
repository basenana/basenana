//
//  DocumentUseCase.swift
//  Domain
//
//  Created by Hypo on 2024/9/18.
//

public class DocumentUseCase: DocumentUseCaseProtocol {

    private var entryRepo: EntryRepositoryProtocol

    public init(entryRepo: EntryRepositoryProtocol) {
        self.entryRepo = entryRepo
    }

    public func listUnreadDocuments(page: Int, pageSize: Int) async throws -> [any EntryInfo] {
        var filter = DocumentFilter()
        filter.page = Pagination()
        filter.page!.page = Int64(page)
        filter.page!.pageSize = Int64(pageSize)
        filter.unread = true
        filter.order = .createdAt
        filter.orderDesc = true
        do {
            return try await entryRepo.ListDocuments(filter: filter)
        } catch RepositoryError.canceled {
            throw UseCaseError.canceled
        }
    }

    public func listMarkedDocuments(page: Int, pageSize: Int) async throws -> [any EntryInfo] {
        var filter = DocumentFilter()
        filter.page = Pagination()
        filter.page!.page = Int64(page)
        filter.page!.pageSize = Int64(pageSize)
        filter.marked = true
        filter.order = .createdAt
        filter.orderDesc = true
        do {
            return try await entryRepo.ListDocuments(filter: filter)
        } catch RepositoryError.canceled {
            throw UseCaseError.canceled
        }
    }

    public func searchDocuments(search: String, page: Int, pageSize: Int) async throws -> [any EntryInfo] {
        var filter = DocumentFilter()
        filter.page = Pagination()
        filter.page!.page = Int64(page)
        filter.page!.pageSize = Int64(pageSize)
        filter.search = search
        filter.order = .createdAt
        filter.orderDesc = true
        do {
            return try await entryRepo.ListDocuments(filter: filter)
        } catch RepositoryError.canceled {
            throw UseCaseError.canceled
        }
    }

    public func getDocumentDetails(uri: String) async throws -> any EntryDetail {
        do {
            return try await entryRepo.GetEntryDetail(uri: uri)
        } catch RepositoryError.canceled {
            throw UseCaseError.canceled
        }
    }

    public func getDocumentEntry(uri: String) async throws -> EntryDetail? {
        do {
            return try await entryRepo.GetEntryDetail(uri: uri)
        } catch RepositoryError.canceled {
            return nil
        }
    }

    public func setDocumentMarkState(uri: String, ismark: Bool) async throws {
        do {
            try await entryRepo.UpdateDocument(uri: uri, unread: nil, marked: ismark)
        } catch RepositoryError.canceled {
            return
        }
    }

    public func setDocumentReadState(uri: String, unread: Bool) async throws {
        do {
            try await entryRepo.UpdateDocument(uri: uri, unread: unread, marked: nil)
        } catch RepositoryError.canceled {
            return
        }
    }
}
