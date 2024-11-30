//
//  EntriesClient.swift
//
//
//  Created by Hypo on 2024/9/16.
//

import Foundation
import GRPC
import Entities
import NetworkCore


@available(macOS 11.0, *)
public class EntriesClient: EntriesClientProtocol {
    
    var entryClient: Api_V1_EntriesAsyncClientProtocol
    var propertyClient: Api_V1_PropertiesAsyncClientProtocol
    
    public init(clientSet: ClientSet) {
        self.entryClient = clientSet.entries
        self.propertyClient = clientSet.properties
    }
    
    public func GroupTree() async throws -> any Entities.Group {
        do {
            let req = Api_V1_GetGroupTreeRequest()
            let resp = try await entryClient.groupTree(req, callOptions: defaultCallOptions)
            
            var root = resp.root.entry.toGroup()!
            root.children = []
            for grp in resp.root.children {
                root.children!.append(paresGroupTreeChild(group: grp))
            }
            
            return root
        } catch let error as GRPCStatusTransformable where error.makeGRPCStatus().code == .cancelled {
            throw RepositoryError.canceled
        } catch {
            throw error
        }
    }
    
    public func RootEntry() async throws -> NetworkCore.APIEntryDetail {
        var req = Api_V1_FindEntryDetailRequest()
        req.root = true
        do{
            let resp = try await entryClient.findEntryDetail(req, callOptions: defaultCallOptions)
            return resp.entry.toEntry(properties: resp.properties)
        } catch let error as GRPCStatusTransformable where error.makeGRPCStatus().code == .cancelled {
            throw RepositoryError.canceled
        } catch {
            throw error
        }
    }
    
    public func FindEntry(parent: Int64, name: String) async throws -> NetworkCore.APIEntryDetail {
        var req = Api_V1_FindEntryDetailRequest()
        req.parentID = parent
        req.name = name
        do{
            let resp = try await entryClient.findEntryDetail(req, callOptions: defaultCallOptions)
            return resp.entry.toEntry(properties: resp.properties)
        } catch let error as GRPCStatusTransformable where error.makeGRPCStatus().code == .cancelled {
            throw RepositoryError.canceled
        } catch {
            throw error
        }
    }
    
    public func GetEntryDetail(entry: Int64) async throws -> NetworkCore.APIEntryDetail {
        var req = Api_V1_GetEntryDetailRequest()
        req.entryID = entry
        do {
            let resp = try await entryClient.getEntryDetail(req, callOptions: defaultCallOptions)
            return resp.entry.toEntry(properties: resp.properties)
        } catch let error as GRPCStatusTransformable where error.makeGRPCStatus().code == .cancelled {
            throw RepositoryError.canceled
        } catch {
            throw error
        }
    }
    
    public func CreateEntry(entry: Entities.EntryCreate) async throws -> NetworkCore.APIEntryInfo {
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
        
        do {
            let resp = try await entryClient.createEntry(req, callOptions: defaultCallOptions)
            return resp.entry.toEntry()
        } catch let error as GRPCStatusTransformable where error.makeGRPCStatus().code == .cancelled {
            throw RepositoryError.canceled
        } catch {
            throw error
        }
    }
    
    public func UpdateEntry(entry: Entities.EntryUpdate) async throws -> NetworkCore.APIEntryDetail {
        var req = Api_V1_UpdateEntryRequest()
        req.entry.id = entry.id
        if entry.name != nil {
            req.entry.name = entry.name!
        }
        
        do {
            let resp = try await entryClient.updateEntry(req, callOptions: defaultCallOptions)
            return resp.entry.toEntry(properties: [])
        } catch let error as GRPCStatusTransformable where error.makeGRPCStatus().code == .cancelled {
            throw RepositoryError.canceled
        } catch {
            throw error
        }
    }
    
    public func DeleteEntries(entrys: [Int64]) async throws {
        var req = Api_V1_DeleteEntriesRequest()
        req.entryIds = entrys
        do {
            let _ = try await entryClient.deleteEntries(req, callOptions: defaultCallOptions)
        } catch let error as GRPCStatusTransformable where error.makeGRPCStatus().code == .cancelled {
            throw RepositoryError.canceled
        } catch {
            throw error
        }
    }
    
    public func ListGroupChildren(filter: EntryFilter) async throws -> [NetworkCore.APIEntryInfo] {
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
        
        do {
            let resp = try await entryClient.listGroupChildren(req, callOptions: defaultCallOptions)
            
            var result: [NetworkCore.APIEntryInfo] = []
            for ch in resp.entries {
                result.append(ch.toEntry())
            }
            return result
        } catch let error as GRPCStatusTransformable where error.makeGRPCStatus().code == .cancelled {
            throw RepositoryError.canceled
        } catch {
            throw error
        }
    }
    
    public func ChangeParent(entry: Int64, newParent: Int64, option: Entities.ChangeParentOption) async throws {
        var req = Api_V1_ChangeParentRequest()
        req.entryID = entry
        req.newParentID = newParent
        req.newName = option.newName
        do {
            let _ = try await entryClient.changeParent(req, callOptions: defaultCallOptions)
        } catch let error as GRPCStatusTransformable where error.makeGRPCStatus().code == .cancelled {
            throw RepositoryError.canceled
        } catch {
            throw error
        }
    }
    
    public func AddProperty(entry: Int64, key: String, val: String) async throws {
        var req = Api_V1_AddPropertyRequest()
        req.entryID = entry
        req.key = key
        req.value = val
        do {
            let _ = try await propertyClient.addProperty(req, callOptions: defaultCallOptions)
        } catch let error as GRPCStatusTransformable where error.makeGRPCStatus().code == .cancelled {
            throw RepositoryError.canceled
        } catch {
            throw error
        }
    }
    
    public func UpdateProperty(entry: Int64, key: String, val: String) async throws {
        var req = Api_V1_UpdatePropertyRequest()
        req.entryID = entry
        req.key = key
        req.value = val
        do {
            let _ = try await propertyClient.updateProperty(req, callOptions: defaultCallOptions)
        } catch let error as GRPCStatusTransformable where error.makeGRPCStatus().code == .cancelled {
            throw RepositoryError.canceled
        } catch {
            throw error
        }
    }
    
    public func DeleteProperty(entry: Int64, key: String) async throws {
        var req = Api_V1_DeletePropertyRequest()
        req.entryID = entry
        req.key = key
        do {
            let _ = try await propertyClient.deleteProperty(req, callOptions: defaultCallOptions)
        } catch let error as GRPCStatusTransformable where error.makeGRPCStatus().code == .cancelled {
            throw RepositoryError.canceled
        } catch {
            throw error
        }
    }
    
}
