//
//  EntryService.swift
//  basenana
//
//  Created by Hypo on 2024/3/7.
//

import Foundation
import SwiftData
import SwiftUI
import GRPC


extension Service {
    
    func getEntry(entryID: Int64) throws -> EntryDetailModel {
        let clientSet = try clientFactory.makeClient()
        var request = Api_V1_GetEntryDetailRequest()
        request.entryID = entryID
        let call = clientSet.entries.getEntryDetail(request, callOptions: defaultCallOptions)
        do {
            let response = try call.response.wait()
            return entryDetail2Model(en: response.entry, properties: response.properties)
        } catch {
            log.error("[EntryService] get entry \(entryID) failed \(error)")
            throw error
        }
    }
    
    func entryDetail2Model(en: Api_V1_EntryDetail, properties: [Api_V1_Property]) -> EntryDetailModel{
        var enProperties: [EntryPropertyModel]=[]
        for property in properties {
            enProperties.append(EntryPropertyModel(key: property.key, value: property.value, encoded: property.encoded))
        }
        return EntryDetailModel(
            id: en.id, name: en.name, aliases: en.aliases, parent: en.parent.id,
            kind: en.kind, isGroup: en.isGroup, size: en.size, version: en.version,
            namespace: en.namespace, storage: en.storage,
            uid: en.access.uid, gid: en.access.gid, permissions: en.access.permissions,
            createdAt: en.changedAt.date, changedAt: en.changedAt.date, modifiedAt: en.modifiedAt.date, accessAt: en.accessAt.date,
            properties: enProperties
        )
    }
    
}

