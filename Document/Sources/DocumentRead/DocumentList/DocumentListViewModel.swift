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


@Observable
@MainActor
public class DocumentListViewModel {
    var prespective: DocumentPrespective
    var store: StateStore
    var usecase: DocumentUseCaseProtocol
    
    // docunents need to display
    var sectionDocuments: [DocumentSection] = []
    var cachedDocuments: [Int64:Bool] = [:]
    
    // document auto read
    var enableHooks = true
    var unreadDocumentsAppeared: [Int64:AppearedDocument] = [:]
    
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
    
    // MARK: document status
    
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
    
    func setAllAppearedDocuemntRead() async {
        for kv in unreadDocumentsAppeared {
            if enableHooks && Date().timeIntervalSince(kv.value.appearedAt) > 10 {
                await setDocumentReadStatus(section: kv.value.section, document: kv.value.documentID, isUnread: false)
                unreadDocumentsAppeared.removeValue(forKey: kv.key)
            }
        }
    }

    // MARK: document hook
    
    func disableHooks() {
        self.enableHooks = false
    }

    func onDocumentAppear(document: DocumentItem) {
        if document.isUnread {
            unreadDocumentsAppeared[document.id] = AppearedDocument(document: document)
        }
    }
    
    func onDocumentDisappear(document: DocumentItem) { }

    // MARK: list document
    func reset() {
        self.page = 1
        print("reinit main documents: current cached \(sectionDocuments.count)")
        sectionDocuments.removeAll()
        cachedDocuments.removeAll()
        self.hasMore = true
        
        self.enableHooks = true
        unreadDocumentsAppeared.removeAll()
    }

    func loadNextPage() async {
        let nextPage = await listNextPage()
        if self.isLoading {
            return
        }
        
        print("list docuemnt len \(nextPage.count)")
        self.isLoading = true
        for nextDoc in nextPage {
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
            
            if nextPageList.isEmpty || pageSize > nextPageList.count {
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
}


