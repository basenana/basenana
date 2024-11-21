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
    
    var mainDocuments: [DocumentItem] = []
    
    var isLoading: Bool = false
    var page: Int = 1
    var pageSize: Int = 20
    var hasMore = true
    
    public init(prespective: DocumentPrespective, store: StateStore, usecase: DocumentUseCaseProtocol) {
        self.prespective = prespective
        self.store = store
        self.usecase = usecase
    }
    
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
    
    func initNextPage() {
        self.page = 1
        let firstPage = listNextPage()
        
        print("reinit main documents: current cached \(mainDocuments.count)")
        mainDocuments = []
        for nextDoc in firstPage {
            mainDocuments.append(DocumentItem(info: nextDoc, keepLowProfile: prespective == .unread && !nextDoc.unread))
        }
    }
    
    func listNextPage() -> [DocumentInfo] {
        var nextPageList: [DocumentInfo] = []
        do {
            switch prespective {
            case .unread:
                nextPageList = try usecase.listUnreadDocuments(page: page, pageSize: pageSize)
            case .marked:
                nextPageList = try usecase.listMarkedDocuments(page: page, pageSize: pageSize)
            }
            
            if nextPageList.isEmpty {
                hasMore = false
            }
            page += 1
        } catch {
            store.alert.display(msg: "list document page failed: \(error)")
        }
        
        return nextPageList
    }

    func checkAndLoadNextPage<Item: Identifiable>(_ item: Item) {
        if hasMore && (mainDocuments.isLastItem(item) || mainDocuments.isEmpty) {
            self.isLoading = true
            let nextPage = listNextPage()
            for nextDoc in nextPage {
                mainDocuments.append(DocumentItem(info: nextDoc, keepLowProfile: prespective == .unread && !nextDoc.unread))
            }
            self.isLoading = false
        }
    }
    
}


struct DocumentItem: Identifiable {
    var id: Int64 {
        get {
            return info.id
        }
    }
    var info: DocumentInfo
    var keepLowProfile: Bool = false
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
