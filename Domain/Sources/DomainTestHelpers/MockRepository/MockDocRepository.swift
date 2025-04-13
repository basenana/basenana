//
//  MockDocRepository.swift
//  Entry
//
//  Created by Hypo on 2024/9/22.
//

import SwiftUI
import Entities
import RepositoryProtocol

var documentsForTest: [MockDocDetail] = [
    .init(id: 1001, oid: 1013, parentId: 1010, name: "file1.3", namespace: "default", marked: true, unread: true, content: "<b>Hello</b> World!", createdAt: Date(), changedAt: Date()),
    .init(id: 1002, oid: 1014, parentId: 1010, name: "file1.4", namespace: "default", marked: true, unread: true, content: "<b>Hello</b> World World World World World World World World World World World World World World World World World World World World! \nHappy to see you", createdAt: Date(), changedAt: Date()),
    .init(id: 1003, oid: 1015, parentId: 1010, name: "hello1.1", namespace: "default", marked: true, unread: true, content: "<b>Hello</b> World World World World World World World World World World World World World World World World World World World World! \nHappy to see you again!", createdAt: Date(), changedAt: Date())
]


public class MockDocRepository: DocumentRepositoryProtocol {
    
    public static var shared = MockDocRepository(data: documentsForTest)
    
    private var repo: [Int64:MockDocDetail] = [:]
    private var groups: [Int64:[Int64]] = [:]
    
    init(data: [MockDocDetail]) {
        for d in data {
            self.repo[d.id] = d
            if self.groups[d.parentId] == nil {
                self.groups[d.parentId] = []
            }
            self.groups[d.parentId]!.append(d.id)
        }
        
    }
    
    public func ListDocuments(filter: Entities.DocumentFilter) throws -> [any Entities.DocumentInfo] {
        var result: [any Entities.DocumentInfo] = []
        if filter.parent != nil {
            let docIds = groups[filter.parent!]
            if docIds == nil {
                return result
            }
            
            for did in docIds! {
                if let d = repo[did]{
                    result.append(d.toInfo())
                }
            }
            return result
        }
        
        for kv in repo {
            if filter.marked ?? false && kv.value.marked  {
                result.append(kv.value.toInfo())
            }
            if filter.unread ?? false && kv.value.unread  {
                result.append(kv.value.toInfo())
            }
            if filter.unread == nil && filter.marked == nil {
                result.append(kv.value.toInfo())
            }
        }
        
        if let page = filter.page {
            var start = Int((page.page-1)*page.pageSize)
            var end = Int(page.page * page.pageSize)
            var page: [any Entities.DocumentInfo] = []

            start = start > result.count ? result.count : start
            end = end > result.count ? result.count : end

            
            if end - start == 0 {
                return page
            }
            
            for i in start..<end {
                page.append(result[i])
            }
            return page
        }
        
        
        return result
    }
    
    public func GetDocumentDetail(id: Entities.DocumentID) throws -> any Entities.DocumentDetail {
        if id.entryID != 0 {
            for d in repo {
                if d.value.oid == id.entryID {
                    return d.value
                }
            }
            throw RepositoryError.notFound
        }
        
        if let d = repo[id.documentID]{
            return d
        }
        throw RepositoryError.notFound
    }
    
    public func UpdateDocument(doc: Entities.DocumentUpdate) throws {
        return
    }
}
