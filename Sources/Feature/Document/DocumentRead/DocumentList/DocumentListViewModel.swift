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

@Observable
@MainActor
public class DocumentListViewModel {
    var prespective: DocumentPrespective
    var store: StateStore
    var usecase: any DocumentUseCaseProtocol
    var fileRepository: FileRepositoryProtocol
    var fridayUseCase: FridayUseCaseProtocol
    var entryUseCase: EntryUseCaseProtocol

    // documents need to display
    var sectionDocuments: [DocumentSection] = []
    var documentsSectionMap: [String: String] = [:]  // URI -> sectionName

    // document auto read
    var enableHooks = true
    var unreadDocumentsAppeared: [String: AppearedDocument] = [:]  // URI -> AppearedDocument

    var isLoading: Bool = false
    var isLoadingMore: Bool = false
    var page: Int = 1
    var pageSize: Int = 10
    var hasMore = true

    private static let logger = Logger(
            subsystem: Bundle.main.bundleIdentifier!,
            category: String(describing: DocumentListViewModel.self)
        )

    public init(
        prespective: DocumentPrespective,
        store: StateStore,
        usecase: any DocumentUseCaseProtocol,
        fileRepository: FileRepositoryProtocol,
        fridayUseCase: FridayUseCaseProtocol,
        entryUseCase: EntryUseCaseProtocol
    ) {
        self.prespective = prespective
        self.store = store
        self.usecase = usecase
        self.fileRepository = fileRepository
        self.fridayUseCase = fridayUseCase
        self.entryUseCase = entryUseCase
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

    func getDocumentEntry(uri: String) async -> EntryDetail? {
        do {
            return try await usecase.getDocumentEntry(uri: uri)
        } catch UseCaseError.canceled {
            // do nothing
        } catch {
            sentAlert("get entry failed: \(error)")
        }
        return nil
    }

    // MARK: document status

    func setDocumentReadStatus(uri: String, isUnread: Bool) async {
        guard let section = documentsSectionMap[uri] else {
            return
        }

        if let s = sectionDocuments.filter( {$0.id == section} ).first {
            for i in s.documents.indices {
                if s.documents[i].uri != uri {
                    continue
                }

                s.documents[i].isUnread = isUnread
                break
            }
        }

        do {
            try await usecase.setDocumentReadState(uri: uri, unread: isUnread)
        } catch {
            sentAlert("set document unread=\(isUnread) failed: \(error)")
        }
    }

    func setDocumentMarkStatus(uri: String, isMark: Bool) async {
        guard let section = documentsSectionMap[uri] else {
            return
        }

        if let s = sectionDocuments.filter( {$0.id == section} ).first {
            for i in s.documents.indices {
                if s.documents[i].uri != uri {
                    continue
                }

                s.documents[i].isMarked = isMark
                break
            }
        }

        do {
            try await usecase.setDocumentMarkState(uri: uri, ismark: isMark)
        } catch {
            sentAlert("set document isMark=\(isMark) failed: \(error)")
        }
    }

    func setAllAppearedDocumentRead(before: Int = 5, isAuto: Bool = true) async {
        if unreadDocumentsAppeared.isEmpty {
            return
        }

        if isAuto {
            if !store.setting.document.autoRead {
                return
            }
            Self.logger.info("auto set all appeared document read")
        }
        for kv in unreadDocumentsAppeared {
            if enableHooks && Date().timeIntervalSince(kv.value.appearedAt) > Double(before) {
                await setDocumentReadStatus(uri: kv.value.uri, isUnread: false)
                unreadDocumentsAppeared.removeValue(forKey: kv.key)
            }
        }
    }

    func setAllDocumentRead() async {
        for section in sectionDocuments {
            for document in section.documents where document.isUnread {
                await setDocumentReadStatus(uri: document.uri, isUnread: false)
            }
        }
    }

    // MARK: document hook

    func disableHooks() {
        self.enableHooks = false
    }

    func onDocumentAppear(document: DocumentItem) {
        if document.isUnread {
            unreadDocumentsAppeared[document.uri] = AppearedDocument(uri: document.uri)
        }
    }

    func onDocumentDisappear(document: DocumentItem) { }

    // MARK: list document
    func reset() {
        self.page = 1
        self.hasMore = true
        self.isLoading = false
        self.isLoadingMore = false
        Self.logger.info("reinit main documents: current cached \(self.sectionDocuments.count)")
        sectionDocuments.removeAll()
        documentsSectionMap.removeAll()

        self.enableHooks = true
        unreadDocumentsAppeared.removeAll()
    }

    func loadNextPage() async {
        guard !isLoading && hasMore && !isLoadingMore else { return }

        Self.logger.info("load next page, page=\(self.page)")
        isLoading = true
        isLoadingMore = true

        let nextPage = await listNextPage()
        Self.logger.info("list document len \(nextPage.count)")

        for nextDoc in nextPage {
            insertToSectionDocuments(doc: DocumentItem(info: nextDoc, readable: prespective == .unread ? true : false))
        }

        isLoading = false
        isLoadingMore = false
    }

    func listNextPage() async -> [EntryInfo] {
        Self.logger.info("ready to list next page document, page=\(self.page)")
        var nextPageList: [EntryInfo] = []
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
            } else {
                self.page += 1
            }
        } catch let error as UseCaseError where error == .canceled {
            // do nothing
            return []
        } catch {
            sentAlert("list document page failed: \(error)")
            return []
        }

        return nextPageList
    }

    func insertToSectionDocuments(doc: DocumentItem) {
        guard documentsSectionMap[doc.uri] == nil else {
            return
        }

        let sid = doc.sectionName
        documentsSectionMap[doc.uri] = sid
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
