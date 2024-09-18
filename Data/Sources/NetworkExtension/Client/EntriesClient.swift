//
//  EntriesClient.swift
//
//
//  Created by Hypo on 2024/9/16.
//

import Foundation
import Entities
import NetworkCore


public class EntriesClient: EntriesClientProtocol {
    
    var entryClient: Api_V1_EntriesClientProtocol
    var propertyClient: Api_V1_PropertiesClientProtocol

    init(entryClient: Api_V1_EntriesClientProtocol, propertyClient: Api_V1_PropertiesClientProtocol) {
        self.entryClient = entryClient
        self.propertyClient = propertyClient
    }
    
    public func GroupTree() throws -> any Entities.Group {
        let req = Api_V1_GetGroupTreeRequest()
        let resp = try entryClient.groupTree(req, callOptions: defaultCallOptions).response.wait()
        
        var root = resp.root.entry.toGroup()!
        root.children = []
        for grp in resp.root.children {
            root.children!.append(paresGroupTreeChild(group: grp))
        }
        
        return root
    }
    
    public func RootEntry() throws -> NetworkCore.APIEntryDetail {
        var req = Api_V1_FindEntryDetailRequest()
        req.root = true
        let resp = try entryClient.findEntryDetail(req, callOptions: defaultCallOptions).response.wait()
        return resp.entry.toEntry(properties: resp.properties)
    }
    
    public func FindEntry(parent: Int64, name: String) throws -> NetworkCore.APIEntryDetail {
        var req = Api_V1_FindEntryDetailRequest()
        req.parentID = parent
        req.name = name
        let resp = try entryClient.findEntryDetail(req, callOptions: defaultCallOptions).response.wait()
        return resp.entry.toEntry(properties: resp.properties)
    }
    
    public func GetEntryDetail(entry: Int64) throws -> NetworkCore.APIEntryDetail {
        var req = Api_V1_GetEntryDetailRequest()
        req.entryID = entry
        let resp = try entryClient.getEntryDetail(req, callOptions: defaultCallOptions).response.wait()
        return resp.entry.toEntry(properties: resp.properties)
    }
    
    public func CreateEntry(entry: Entities.EntryCreate) throws -> NetworkCore.APIEntryInfo {
        var req = Api_V1_CreateEntryRequest()
        req.parentID = entry.parent
        req.name = entry.name
        req.kind = entry.kind
        
        if entry.RSS != nil {
            req.rss = Api_V1_CreateEntryRequest.RssConfig()
            req.rss.feed = entry.RSS!.feed
            req.rss.siteName = entry.RSS!.siteName
            req.rss.siteURL = entry.RSS!.siteURL
            
            switch entry.RSS!.fileType {
            case .Bookmark:
                req.rss.fileType = .bookmarkFile
            case .Html:
                req.rss.fileType = .htmlFile
            case .Webarchive:
                req.rss.fileType = .webArchiveFile
            }
        }
        
        let resp = try entryClient.createEntry(req, callOptions: defaultCallOptions).response.wait()
        return resp.entry.toEntry()
    }
    
    public func UpdateEntry(entry: Entities.EntryUpdate) throws -> NetworkCore.APIEntryDetail {
        var req = Api_V1_UpdateEntryRequest()
        req.entry.id = entry.id
        if entry.name != nil {
            req.entry.name = entry.name!
        }
        
        let resp = try entryClient.updateEntry(req, callOptions: defaultCallOptions).response.wait()
        return resp.entry.toEntry(properties: [])
    }
    
    public func DeleteEntries(entrys: [Int64]) throws {
        var req = Api_V1_DeleteEntriesRequest()
        req.entryIds = entrys
        let _ = try entryClient.deleteEntries(req, callOptions: defaultCallOptions).response.wait()
    }
    
    public func ListGroupChildren(filter: EntryFilter) throws -> [NetworkCore.APIEntryInfo] {
        var req = Api_V1_ListGroupChildrenRequest()
        req.parentID = filter.parent
        
        if filter.kind != nil {
            req.filter.kind = filter.kind!
        }
        
        if filter.fileOnly != nil && filter.fileOnly! {
            req.filter.isGroup = .file
        }
        if filter.groupOnly != nil && filter.groupOnly! {
            req.filter.isGroup = .group
        }
        
        switch filter.order {
        case .none:
            req.order = .name
        case .some(.name):
            req.order = .name
        case .some(.kind):
            req.order = .kind
        case .some(.isGroup):
            req.order = .isGroup
        case .some(.size):
            req.order = .size
        case .some(.modifiedAt):
            req.order = .modifiedAt
        case .some(.createdAt):
            req.order = .createdAt
        }
        if filter.orderDesc != nil {
            req.orderDesc = filter.orderDesc!
        }

        if filter.page != nil {
            req.pagination = Api_V1_Pagination()
            req.pagination.page = filter.page!.page
            req.pagination.pageSize = filter.page!.pageSize
        }

        let resp = try entryClient.listGroupChildren(req, callOptions: defaultCallOptions).response.wait()
        
        var result: [NetworkCore.APIEntryInfo] = []
        for ch in resp.entries {
            result.append(ch.toEntry())
        }
        return result
    }
    
    public func ChangeParent(entry: Int64, newParent: Int64, option: Entities.ChangeParentOption) throws {
        var req = Api_V1_ChangeParentRequest()
        req.entryID = entry
        req.newParentID = newParent
        let _ = try entryClient.changeParent(req, callOptions: defaultCallOptions).response.wait()
    }
    
    public func AddProperty(entry: Int64, key: String, val: String) throws {
        var req = Api_V1_AddPropertyRequest()
        req.entryID = entry
        req.key = key
        req.value = val
        let _ = try propertyClient.addProperty(req, callOptions: defaultCallOptions).response.wait()
    }
    
    public func UpdateProperty(entry: Int64, key: String, val: String) throws {
        var req = Api_V1_UpdatePropertyRequest()
        req.entryID = entry
        req.key = key
        req.value = val
        let _ = try propertyClient.updateProperty(req, callOptions: defaultCallOptions).response.wait()
    }
    
    public func DeleteProperty(entry: Int64, key: String) throws {
        var req = Api_V1_DeletePropertyRequest()
        req.entryID = entry
        req.key = key
        let _ = try propertyClient.deleteProperty(req, callOptions: defaultCallOptions).response.wait()
    }
    
}
