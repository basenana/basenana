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

extension Service {
    
    func ingestDocument(entryId: Int64) throws {
        let clientSet = try clientFactory.makeClient()
        var requset = Api_V1_TriggerWorkflowRequest()
        requset.workflowID = "buildin.ingest"
        requset.target.entryID = entryId
        let call = clientSet.workflow.triggerWorkflow(requset, callOptions: defaultCallOptions)
        do {
            let _ = try call.response.wait()
        } catch {
            log.error("trigger workflow failed \(error)")
            throw error
        }
    }
    
    func searchDocument(search: String) throws -> [DocumentInfoModel] {
        let clientSet = try clientFactory.makeClient()
        var request = Api_V1_SearchDocumentsRequest()
        request.query = search

        let call = clientSet.document.searchDocuments(request, callOptions: defaultCallOptions)

        do {
            let response = try call.response.wait()
            var docs: [DocumentInfoModel] = []
            
            for d in response.documents {
                docs.append(docInfo2Model(doc: d))
            }
            return docs
        } catch {
            log.error("search document failed \(error)")
            throw error
        }
    }
    
    func docInfo2Model(doc: Api_V1_DocumentInfo) -> DocumentInfoModel{
        return DocumentInfoModel(
            id: doc.id, oid: doc.entryID, parentId: doc.parentEntryID, name: doc.name, namespace: doc.namespace, source: doc.source,
            marked: doc.marked, unread: doc.unread, subContent: doc.subContent,
            createdAt: doc.createdAt.date, changedAt: doc.changedAt.date)
    }
}
