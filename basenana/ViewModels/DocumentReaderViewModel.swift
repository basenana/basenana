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
    
    static func load(prespective : DocumentPrespective) async throws -> DocumentReaderViewModel {
        let vm = DocumentReaderViewModel()
        vm.prespective = prespective
        try await vm.loadNextPageDocuments()

        let clientSet = try clientFactory.makeClient()
        var request = Api_V1_GetDocumentParentsRequest()
        
        switch prespective {
        case .none:
            return vm
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
            for grp in response.entries.map({ $0.toEntry() }){
                vm.documentGroups.append(grp)
            }
        } catch {
            log.error("list docuemnt parent failed \(error)")
            throw error
        }
        return vm
    }

    func initFirstPageDocuments(prespective : DocumentPrespective) async throws {
        try await waitingForLoading()
        self.isLoading = true
        log.info("start init first page")
        defer {
            self.isLoading = false
            log.info("finish init first page")
        }
        if self.prespective != .none {
            return
        }

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
            for grp in response.entries.map({ $0.toEntry() }){
                documentGroups.append(grp)
            }
        } catch {
            log.error("list docuemnt parent failed \(error)")
            throw error
        }
    }
    
    func reloadNextPageDocuments() async throws {
        try await waitingForLoading()
        self.isLoading = true
        log.info("start reload next page")
        defer {
            self.isLoading = false
            log.info("finish reload next page")
        }
        
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
            try await waitingForLoading()
            self.isLoading = true
            log.info("start load next page")
            defer {
                self.isLoading = false
                log.info("finish load next page")
            }
            try await loadNextPageDocuments()
        }
    }
    
    func waitingForLoading() async throws {
        var waitTime = 0
        try await Task.sleep(for: .microseconds(arc4random() % 10))
        
        while self.isLoading {
            try await Task.sleep(for: .microseconds(arc4random() % 100 + 10))
            waitTime += 1
            if waitTime % 10 == 0 {
                log.warning("wating for loading too long")
            }
        }
    }
}

