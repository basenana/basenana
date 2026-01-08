//
//  DocumentListViewModel.swift
//  Entry
//
//  Created by Hypo on 2024/11/16.
//

import os
import SwiftUI
import Foundation
import Domain
import Domain
import Domain


@Observable
@MainActor
public class DocumentListViewModel {
    var prespective: DocumentPrespective
    var store: StateStore
    var usecase: any DocumentUseCaseProtocol

    // docunents need to display
    var sectionDocuments: [DocumentSection] = []
    var documentsSectionMap: [Int64:String] = [:]

    // document auto read
    var enableHooks = true
    var unreadDocumentsAppeared: [Int64:AppearedDocument] = [:]

    var isLoading: Bool = false
    var page: Int = 1
    var pageSize: Int = 40
    var hasMore = true

    private static let logger = Logger(
            subsystem: Bundle.main.bundleIdentifier!,
            category: String(describing: DocumentListViewModel.self)
        )

    public init(prespective: DocumentPrespective, store: StateStore, usecase: any DocumentUseCaseProtocol) {
        self.prespective = prespective
        self.store = store
        self.usecase = usecase
    }
    
    
    // list display
    
    func getListViewKind() -> ListViewKind{
        var kindConfig: String = ""
        if prespective == .marked {
            kindConfig = store.setting.appearance.markedReadModel
        }else {
            kindConfig = store.setting.appearance.unreadReadModel
        }
        
        switch kindConfig {
        case "masonry":
            return .Masonry
        case "navigation":
            return .Navigation
        default:
            if prespective == .marked {
                return .Navigation
            }else {
                return .Masonry
            }
        }
    }
    
    var showImagePreview: Bool {
        return store.setting.appearance.imagePreview != "none"
    }
    
    var showTextPreview: Bool {
        return store.setting.appearance.contentPreview
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
    
    func setDocumentReadStatus(document: Int64, isUnread: Bool) async {
        guard let section = documentsSectionMap[document] else {
            return
        }
        
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
    
    func setDocumentMarkStatus(document: Int64, isMark: Bool) async {
        guard let section = documentsSectionMap[document] else {
            return
        }
        
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
    
    func setAllAppearedDocuemntRead(before: Int = 30, isAuto: Bool = true) async {
        if unreadDocumentsAppeared.isEmpty {
            return
        }
        
        if isAuto {
            if !store.setting.document.autoRead {
                return
            }
            Self.logger.info("auto set all appeared docuemnt read")
        }
        for kv in unreadDocumentsAppeared {
            if enableHooks && Date().timeIntervalSince(kv.value.appearedAt) > Double(before) {
                await setDocumentReadStatus(document: kv.value.documentID, isUnread: false)
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
        Self.logger.info("reinit main documents: current cached \(self.sectionDocuments.count)")
        sectionDocuments.removeAll()
        documentsSectionMap.removeAll()
        self.hasMore = true
        
        self.enableHooks = true
        unreadDocumentsAppeared.removeAll()
    }
    
    func loadNextPage() async {
        let nextPage = await listNextPage()
        if self.isLoading {
            return
        }
        
        Self.logger.info("list docuemnt len \(nextPage.count)")
        self.isLoading = true
        for nextDoc in nextPage {
            insertToSectionDocuments(doc: DocumentItem(info: nextDoc, readable: prespective == .unread ? true : false))
        }
        self.isLoading = false
    }
    
    func listNextPage() async -> [DocumentInfo] {
        Self.logger.info("ready to list next page document, page=\(self.page)")
        var nextPageList: [DocumentInfo] = []
        do {
            switch prespective {
            case .unread:
                nextPageList = try await usecase.listUnreadDocuments(page: page, pageSize: pageSize)
            case .marked:
                nextPageList = try await usecase.listMarkedDocuments(page: page, pageSize: pageSize)
            }
            
            if nextPageList.isEmpty || pageSize > nextPageList.count {
                Self.logger.info("no more documents, page=\(self.page)")
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
        guard documentsSectionMap[doc.id] == nil else {
            return
        }
        
        let sid = doc.sectionName
        documentsSectionMap[doc.id] = sid
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


