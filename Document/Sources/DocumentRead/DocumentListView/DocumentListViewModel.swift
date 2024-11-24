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
    
    func getDocumentEntry(entry: Int64) -> EntryDetail? {
        do {
            return try usecase.getDocumentEntry(entry: entry)
        } catch {
            store.alert.display(msg: "get entry failed: \(error)")
        }
        return nil
    }
    
    func getDocumentEntry(docID: Int64) -> EntryDetail? {
        do {
            return try usecase.getDocumentEntry(document: docID)
        } catch {
            store.alert.display(msg: "get document entry failed: \(error)")
        }
        return nil
    }
    
    // document mark
    
    func setDocumentReadStatus(section: String, document: Int64, isUnread: Bool) {
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
            try usecase.setDocumentReadState(document: document, unread: isUnread)
        } catch {
            store.alert.display(msg: "set document unread=\(isUnread) failed: \(error)")
        }
    }
    
    func setDocumentMarkStatus(section: String, document: Int64, isMark: Bool) {
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
            try usecase.setDocumentMarkState(document: document, ismark: isMark)
        } catch {
            store.alert.display(msg: "set document isMark=\(isMark) failed: \(error)")
        }
    }
    
    // list document
    
    func initNextPage() {
        self.page = 1
        let firstPage = listNextPage()
        self.isLoading = true
        
        print("reinit main documents: current cached \(sectionDocuments.count)")
        sectionDocuments.removeAll()
        cachedDocuments.removeAll()
        for nextDoc in firstPage {
            insertToSectionDocuments(doc: DocumentItem(info: nextDoc, readable: prespective == .unread ? true : false))
        }
        self.isLoading = false
    }
    
    func listNextPage() -> [DocumentInfo] {
        print("ready to list next page document, page=\(page)")
        var nextPageList: [DocumentInfo] = []
        do {
            switch prespective {
            case .unread:
                nextPageList = try usecase.listUnreadDocuments(page: page, pageSize: pageSize)
            case .marked:
                nextPageList = try usecase.listMarkedDocuments(page: page, pageSize: pageSize)
            }
            
            if nextPageList.isEmpty {
                print("no more documents, page=\(page)")
                hasMore = false
            }
            page += 1
        } catch {
            store.alert.display(msg: "list document page failed: \(error)")
        }
        
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
    
    func checkAndLoadNextPage<Item: Identifiable>(_ section: String, _ item: Item) {
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
        let nextPage = listNextPage()
        for nextDoc in nextPage {
            insertToSectionDocuments(doc: DocumentItem(info: nextDoc, readable: prespective == .unread ? true : false))
        }
        self.isLoading = false
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
