//
//  DocumentListViewModel.swift
//  Entry
//
//  Created by Hypo on 2024/11/16.
//

import SwiftUI
import Foundation
import Entities
import UseCase
import AppState

enum ListMode {
    case Unread
    case Marked
}


@available(macOS 14.0, *)
@Observable
@MainActor
public class DocumentListViewModel {
    var listModel: ListMode
    var store: StateStore
    var usercase: DocumentUseCase
    var mainDocuments: [DocumentItem] = []
    var selection: Set<DocumentItem.ID> = []
    var documentProperties: [Int64:[EntryProperty]] = [:]
    
    var isLoading: Bool = false
    var page: Int = 1
    var pageSize: Int = 20
    var hasMore = true
    
    init(listModel: ListMode, store: StateStore, usercase: DocumentUseCase) {
        self.listModel = listModel
        self.store = store
        self.usercase = usercase
    }
    
    func initDocumentProperties(doc: DocumentItem) {
    }
    
    func getDocumentProperties(docID: Int64, key: String) -> EntryProperty? {
        return nil
    }
        
    func listNextPage() {
        var nextPage: [DocumentInfo] = []
        switch listModel {
        case .Unread:
            nextPage = try! usercase.listUnreadDocuments(page: page, pageSize: pageSize)
        case .Marked:
            nextPage = try! usercase.listMarkedDocuments(page: page, pageSize: pageSize)
        }
        
        page += 1
        if nextPage.isEmpty {
            hasMore = false
        }
        for nextDoc in nextPage {
            mainDocuments.append(DocumentItem(info: nextDoc, keepLowProfile: listModel == .Unread && !nextDoc.unread))
        }
    }

    func checkAndLoadNextPage<Item: Identifiable>(_ item: Item) {
        if hasMore && (mainDocuments.isLastItem(item) || mainDocuments.isEmpty) {
            self.isLoading = true
            listNextPage()
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
