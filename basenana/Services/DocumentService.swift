//
//  DocumentService.swift
//  basenana
//
//  Created by zww on 2024/3/25.
//

import SwiftData
import Foundation
import SwiftUI
import GRPC
import GRDB

let documentService = DocumentService()

class DocumentService {
    
    func getDocument(entryId: Int64) -> DocumentDetailModel? {
        var request = Api_V1_GetDocumentDetailRequest()
        request.entryID = entryId
        let call = clientSet!.document.getDocumentDetail(request, callOptions: defaultCallOptions)
        
        do {
            let response = try call.response.wait()
            return docDetail2Model(doc: response.document)
        } catch{
            log.error("[documentService] get document detail failed \(error)")
            return nil
        }
    }
    
    func listDocuments(filter: Docfilter? = nil, order: DocumentOrder? = nil, pages: Pagination? = nil) -> [DocumentInfoModel]{
        do {
            var request = Api_V1_ListDocumentsRequest()
            if let f = filter {
                request.filter = Api_V1_DocumentFilter()
                if let marked = f.marked {
                    request.filter.marked = marked
                }
                if let unread = f.unread {
                    request.filter.unread = unread
                }
                if let parentId = f.parentId {
                    request.parentID = parentId
                }
            }
            
            if let ps = pages {
                request.pagination = Api_V1_Pagination()
                request.pagination.page = ps.page
                request.pagination.pageSize = ps.pageSize
            }
            
            if let o = order {
                switch o.order {
                case DocOrder.createAt:
                    request.order = Api_V1_ListDocumentsRequest.DocumentOrder.createdAt
                case .name:
                    request.order = Api_V1_ListDocumentsRequest.DocumentOrder.name
                }
                if o.desc == true {
                    request.orderDesc = true
                }
            }
            
            let call = clientSet?.document.listDocuments(request, callOptions: defaultCallOptions)
            let response =  try call?.response.wait()
            
            let documents = response!.documents
            var docs: [DocumentInfoModel] = []
            for doc in documents {
                docs.append(docInfo2Model(doc: doc))
            }
            return docs
        } catch {
            log.error("[documentService] list docuemnt failed \(error)")
            return []
        }
    }
    
    func updateDocument(docUpdate: DocumentUpdate) {
        var doc: DocumentInfoModel?
        do {
            var request = Api_V1_UpdateDocumentRequest()
            request.document.id = docUpdate.docId
            if let unread = docUpdate.unread {
                request.setMark = unread ? Api_V1_UpdateDocumentRequest.DocumentMark.unread:Api_V1_UpdateDocumentRequest.DocumentMark.read
                doc?.unread = unread
            }
            if let mark = docUpdate.marked {
                request.setMark = mark ? Api_V1_UpdateDocumentRequest.DocumentMark.marked:Api_V1_UpdateDocumentRequest.DocumentMark.unmarked
                doc?.marked = mark
            }
            
            let call = clientSet?.document.updateDocument(request, callOptions: defaultCallOptions)
            let _ = try call?.response.wait()
        } catch {
            log.error("[documentService] update docuemnt failed \(error)")
        }
        return
    }
    
    func ingestDocument(entryId: Int64){
        var requset = Api_V1_TriggerWorkflowRequest()
        requset.workflowID = "buildin.ingest"
        requset.target.entryID = entryId
        
        do {
            let call = clientSet!.workflow.triggerWorkflow(requset, callOptions: defaultCallOptions)
            let _ = try call.response.wait()
        } catch {
            log.error("trigger workflow failed \(error)")
            return
        }
    }
    
    func searchDocument(search: String) -> [DocumentInfoModel] {
        
        do {
            var request = Api_V1_SearchDocumentsRequest()
            request.query = search

            let call = clientSet!.document.searchDocuments(request, callOptions: defaultCallOptions)
            let response = try call.response.wait()
            var docs: [DocumentInfoModel] = []
            
            for d in response.documents {
                docs.append(docInfo2Model(doc: d))
            }
            return docs
        } catch {
            log.error("search document failed \(error)")
            return []
        }
        
    }
    
    func listDocumentGroups(parentId: Int64?, filter: Docfilter?) -> [EntryInfoModel] {
        do {
            var request = Api_V1_GetDocumentParentsRequest()
            if let f = filter {
                request.filter = Api_V1_DocumentFilter()
                if let marked = f.marked {
                    request.filter.marked = marked
                }
                if let unread = f.unread {
                    request.filter.unread = unread
                }
            }
            if let pId = parentId {
                request.parentID = pId
            }

            let call = clientSet?.document.getDocumentParents(request, callOptions: defaultCallOptions)
            let response =  try call?.response.wait()
            
            var ens: [EntryInfoModel] = []
            for en in response?.entries ?? [] {
                ens.append(entryService.entryInfo2Model(en: en))
            }
            return ens
        } catch {
            log.error("[documentService] list docuemnt failed \(error)")
            return []
        }

    }
    
    func docDetail2Model(doc: Api_V1_DocumentDescribe) -> DocumentDetailModel {
        return DocumentDetailModel(
            id: doc.id, oid: doc.entryID, parentId: doc.parentEntryID, name: doc.name, namespace: doc.namespace, source: doc.source,
            marked: doc.marked, unread: doc.unread, keyWords: doc.keyWords, content: doc.htmlContent, summary: doc.summary,
            createdAt: doc.createdAt.date, changedAt: doc.changedAt.date)
    }
    
    func docInfo2Model(doc: Api_V1_DocumentInfo) -> DocumentInfoModel{
        return DocumentInfoModel(
            id: doc.id, oid: doc.entryID, parentId: doc.parentEntryID, name: doc.name, namespace: doc.namespace, source: doc.source,
            marked: doc.marked, unread: doc.unread, subContent: doc.subContent,
            createdAt: doc.createdAt.date, changedAt: doc.changedAt.date)
    }
    
    func docDetail2Info(doc: DocumentDetailModel) -> DocumentInfoModel {
        return DocumentInfoModel(
            id: doc.id, oid: doc.oid, parentId: doc.parentId, name: doc.name, namespace: doc.namespace, source: doc.source,
            marked: doc.marked, unread: doc.unread, subContent: doc.content,
            createdAt: doc.createdAt, changedAt: doc.changedAt)
    }
}
