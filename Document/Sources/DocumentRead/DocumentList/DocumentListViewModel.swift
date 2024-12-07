//
//  DocumentListViewModel.swift
//  Entry
//
//  Created by Hypo on 2024/11/16.
//

import SwiftUI
import Foundation
import Entities
import AppState
import UseCaseProtocol


@available(macOS 14.0, *)
@Observable
@MainActor
public class DocumentListViewModel {
    var prespective: DocumentPrespective
    var store: StateStore
    var usecase: DocumentUseCaseProtocol
    
    // docunents need to display
    var sectionDocuments: [DocumentSection] = []
    var cachedDocuments: [Int64:Bool] = [:]
    
    var isLoading: Bool = false
    var page: Int = 1
    var pageSize: Int = 40
    var hasMore = true
    
    public init(prespective: DocumentPrespective, store: StateStore, usecase: DocumentUseCaseProtocol) {
        self.prespective = prespective
        self.store = store
        self.usecase = usecase
    }
    
    // entry
    
    func getDocumentEntry(entry: Int64) async -> EntryDetail? {
        do {
            return try await usecase.getDocumentEntry(entry: entry)
        } catch UseCaseError.canceled {
            // do nothing
        } catch {
            sentAlert("get entry failed: \(error)")
        }
        return nil
    }
    
    func getDocumentEntry(docID: Int64) async -> EntryDetail? {
        do {
            return try await usecase.getDocumentEntry(document: docID)
        } catch let error as UseCaseError where error == .canceled {
            // do nothing
        } catch {
            sentAlert("get document entry failed: \(error)")
        }
        return nil
    }
    
    // document mark
    
    func setDocumentReadStatus(section: String, document: Int64, isUnread: Bool) async {
        if let s = sectionDocuments.filter( {$0.id == section} ).first {
            for i in s.documents.indices {
                if s.documents[i].id != document {
                    continue
                }
                
                s.documents[i].isUnread = isUnread
                break
            }
        }
        
        do {
            try await usecase.setDocumentReadState(document: document, unread: isUnread)
        } catch {
            sentAlert("set document unread=\(isUnread) failed: \(error)")
        }
    }
    
    func setDocumentMarkStatus(section: String, document: Int64, isMark: Bool) async {
        if let s = sectionDocuments.filter( {$0.id == section} ).first {
            for i in s.documents.indices {
                if s.documents[i].id != document {
                    continue
                }
                
                s.documents[i].isMarked = isMark
                break
            }
        }
        
        do {
            try await usecase.setDocumentMarkState(document: document, ismark: isMark)
        } catch {
            sentAlert("set document isMark=\(isMark) failed: \(error)")
        }
    }
    
    // list document
    
    func initNextPage() async {
        self.page = 1
        let firstPage = await listNextPage()
        self.isLoading = true
        
        print("reinit main documents: current cached \(sectionDocuments.count)")
        sectionDocuments.removeAll()
        cachedDocuments.removeAll()
        for nextDoc in firstPage {
            insertToSectionDocuments(doc: DocumentItem(info: nextDoc, readable: prespective == .unread ? true : false))
        }
        self.isLoading = false
    }
    
    func listNextPage() async -> [DocumentInfo] {
        print("ready to list next page document, page=\(page)")
        var nextPageList: [DocumentInfo] = []
        do {
            switch prespective {
            case .unread:
                nextPageList = try await usecase.listUnreadDocuments(page: page, pageSize: pageSize)
            case .marked:
                nextPageList = try await usecase.listMarkedDocuments(page: page, pageSize: pageSize)
            }
            
            if nextPageList.isEmpty {
                print("no more documents, page=\(page)")
                hasMore = false
            }
        } catch let error as UseCaseError where error == .canceled {
            // do nothing
            return []
        } catch {
            sentAlert("list document page failed: \(error)")
            return []
        }
        
        page += 1
        return nextPageList
    }
    
    func insertToSectionDocuments(doc: DocumentItem) {
        guard cachedDocuments[doc.id] == nil else {
            return
        }
        
        cachedDocuments[doc.id] = true
        let sid = doc.sectionName
        for i in sectionDocuments.indices {
            if sectionDocuments[i].id == sid {
                sectionDocuments[i].documents.append(doc)
                return
            }
        }
        
        let s = DocumentSection(id: sid, documents: [doc])
        sectionDocuments.append(s)
    }
    
    func checkAndLoadNextPage<Item: Identifiable>(_ section: String, _ item: Item) async {
        guard hasMore else {
            return
        }
        
        if let section = sectionDocuments.filter({$0.id == section}).first {
            if !sectionDocuments.isLastItem(section) {
                return
            }
            if !section.documents.isLastItem(item) && !section.documents.isEmpty {
                return
            }
        }
        
        self.isLoading = true
        defer {
            self.isLoading = false
        }
        let nextPage = await listNextPage()
        for nextDoc in nextPage {
            insertToSectionDocuments(doc: DocumentItem(info: nextDoc, readable: prespective == .unread ? true : false))
        }
    }
}


extension RandomAccessCollection where Self.Element: Identifiable {
    func isLastItem<Item: Identifiable>(_ item: Item) -> Bool {
        guard !isEmpty else {
            return false
        }
        
        guard let itemIndex = firstIndex(where: { $0.id.hashValue == item.id.hashValue }) else {
            return false
        }
        
        let distance = self.distance(from: itemIndex, to: endIndex)
        return distance == 1
    }
}
