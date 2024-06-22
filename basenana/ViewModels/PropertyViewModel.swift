//
//  DocumentpPropertyViewModel.swift
//  basenana
//
//  Created by Hypo on 2024/6/22.
//

import Foundation


@Observable
class PropertyViewModel {
    var entryID: Int64 = 0
    var entryName: String = ""
    var entryAliases: String = ""
    var parentName: String = ""
    var isGroup: Bool = false
    
    var createdAt: Date = Date()
    var changedAt: Date = Date()
    var modifiedAt: Date = Date()
    
    var properties: [EntryPropertyModel] = []
    
    func initEntry(entryID: Int64) async throws{
        self.entryID = entryID
        
        let clientSet = try clientFactory.makeClient()
        var request = Api_V1_GetEntryDetailRequest()
        request.entryID = entryID
        let call = clientSet.entries.getEntryDetail(request, callOptions: defaultCallOptions)
        let response = try await call.response.get()
        
        self.entryName = response.entry.name
        self.entryAliases = response.entry.aliases
        self.parentName = response.entry.parent.name
        self.isGroup = response.entry.isGroup
        
        self.createdAt = response.entry.createdAt.date
        self.changedAt = response.entry.changedAt.date
        self.modifiedAt = response.entry.modifiedAt.date

        self.properties = response.properties.filter({ !$0.encoded }).map({ $0.toEntryProperty() })
    }
    
    func getProperty(k: String) -> EntryPropertyModel?{
        for property in properties {
            if property.key == k{
                return property
            }
        }
        return nil
    }
}
