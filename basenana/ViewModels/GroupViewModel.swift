//
//  GroupViewModel.swift
//  basenana
//
//  Created by Hypo on 2024/3/23.
//

import Foundation


@Observable
class GroupViewModel {
    var id: Int64 = 0
    var children: [EntryInfoModel] = []
    
    var selection: Set<EntryInfoModel.ID> = []
    var document: DocumentDetailModel? = nil
    
    static func load(groupID: Int64) async throws -> GroupViewModel {
        let vm = GroupViewModel()
        try await vm.fetchChildren(groupID: groupID)
        return vm
    }

    func fetchChildren(groupID: Int64) async throws  {
        self.id = groupID
        let clientSet = try ClientFactory.share.makeClient()
        
        var req = Api_V1_ListGroupChildrenRequest()
        req.parentID = groupID
        req.order = Api_V1_ListGroupChildrenRequest.EntryOrder.modifiedAt
        
        do {
            let call = clientSet.entries.listGroupChildren(req, callOptions: defaultCallOptions)
            let response = try await call.response.get()
            self.children = response.entries.filter({ !$0.name.hasPrefix(".") }).map({$0.toEntry()})
        } catch {
            log.error("list children of \(groupID) failed \(error)")
            throw error
        }
    }
    
    func fetchSelectedDocument() async throws  {
        if selection.isEmpty || selection.count > 1 {
            return
        }
        
        let enID = selection.first!
        var en: EntryInfoModel?
        for oneEn in self.children {
            if oneEn.id == enID {
                en = oneEn
            }
        }
        if en == nil {
            return
        }
        
        if en!.isGroup {
            return
        }
        
        let clientSet = try ClientFactory.share.makeClient()
        var req = Api_V1_GetDocumentDetailRequest()
        req.entryID = en!.id
        
        do {
            let call = clientSet.document.getDocumentDetail(req, callOptions: defaultCallOptions)
            let response = try await call.response.get()
            self.document = response.document.toDocuement()
        } catch {
            log.error("get docuemnt with entry id \(en!.id) failed \(error)")
            throw error
        }
        
        return
    }
}

