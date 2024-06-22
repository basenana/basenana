//
//  DocumentReaderViewModel.swift
//  basenana
//
//  Created by Hypo on 2024/6/22.
//

import Foundation


@Observable
class DocumentReaderViewModel {
    var prespective : DocumentPrespective = .none
    
    var isLoading: Bool = false
    var page: Int64 = 1
    var pageSize: Int64 = 20
    var hasMore = true
    
    var documents: [DocumentInfoModel] = []
    var selection: DocumentInfoModel?
    
    var readed: Set<DocumentInfoModel.ID> = []
    var marked: Set<DocumentInfoModel.ID> = []
    
    var documentGroups: [EntryInfoModel] = []
    var groupFilter: Int64 = 0
    
    var needAutoReadDocument: Set<DocumentInfoModel.ID> = []
    
    func initFirstPageDocuments(prespective : DocumentPrespective) async throws {
        self.prespective = prespective
        try await loadNextPageDocuments()
        
        let clientSet = try clientFactory.makeClient()
        var request = Api_V1_GetDocumentParentsRequest()
        
        switch prespective {
        case .none:
            return
        case .unread:
            request.filter = Api_V1_DocumentFilter()
            request.filter.unread = true
        case .marked:
            request.filter = Api_V1_DocumentFilter()
            request.filter.marked = true
        }
        
        do {
            let call = clientSet.document.getDocumentParents(request, callOptions: defaultCallOptions)
            let response = try await call.response.get()
            documentGroups = response.entries.map({ $0.toEntry() })
        } catch {
            log.error("list docuemnt parent failed \(error)")
            throw error
        }
    }
    
    func reloadNextPageDocuments() async throws {
        self.page = 1
        self.documents = []
        try await loadNextPageDocuments()
    }
    
    func loadNextPageDocuments() async throws {
        let clientSet = try clientFactory.makeClient()
        var request = Api_V1_ListDocumentsRequest()
        switch prespective {
        case .none:
            return
        case .unread:
            request.filter = Api_V1_DocumentFilter()
            request.filter.unread = true
        case .marked:
            request.filter = Api_V1_DocumentFilter()
            request.filter.marked = true
        }
        
        if groupFilter > 0 {
            request.parentID = groupFilter
        }
        
        request.pagination = Api_V1_Pagination()
        request.pagination.page = page
        request.pagination.pageSize = pageSize
        request.order = Api_V1_ListDocumentsRequest.DocumentOrder.createdAt
        request.orderDesc = true
        
        let call = clientSet.document.listDocuments(request, callOptions: defaultCallOptions)
        do {
            let response = try await call.response.get()
            if response.documents.isEmpty{
                hasMore = false
                return
            }
            
            for d in response.documents {
                if !d.unread {
                    readed.insert(d.id)
                }
                if d.marked {
                    marked.insert(d.id)
                }
                documents.append(d.toDocuement())
            }
        } catch {
            log.error("list docuemnt failed \(error)")
            throw error
        }
        page += 1
    }
    
    func isMarkDocumentsReaded(doc: DocumentInfoModel) -> Bool {
        switch prespective {
        case .unread:
            return readed.contains(doc.id) ? true : false
        default:
            return false
        }
    }
    
    func checkAndLoadNextPage<Item: Identifiable>(_ item: Item) async throws {
        if hasMore && documents.isLastItem(item) {
            isLoading = true
            try await loadNextPageDocuments()
            self.isLoading = false
        }
    }
}
