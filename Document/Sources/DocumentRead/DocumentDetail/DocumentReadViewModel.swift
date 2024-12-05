//
//  DocumentReadViewModel.swift
//  Document
//
//  Created by Hypo on 2024/11/18.
//
import SwiftUI
import Foundation
import Entities
import AppState
import UseCaseProtocol


@Observable
@MainActor
public class DocumentReadViewModel {
    var docID: Int64
    var store: StateStore
    var usecase: DocumentUseCaseProtocol
    
    var document: DocumentDetail? = nil
    var entry: EntryDetail? = nil

    public init(docID:Int64, store: StateStore, usecase: DocumentUseCaseProtocol) {
        self.docID = docID
        self.store = store
        self.usecase = usecase
    }
    
    func loadDocument() async {
        do {
            entry = try await usecase.getDocumentEntry(document: docID)
            document = try await usecase.getDocumentDetails(document: docID)
        } catch {
            store.alert.display(msg: "load document failed: \(error)")
        }
    }
    
    var targetURL: URL? {
        get {
            if let pro = getEntryProperty(keys: [Property.WebPageURL, Property.WebSiteURL]) {
                if let u = URL(string: pro.value) {
                    return u
                }
            }
            return nil
        }
    }
    
    func getEntryProperty(keys: [String]) -> EntryProperty? {
        guard entry != nil else {
            return nil
        }
        for k in keys {
            for p in entry!.properties {
                if p.key == k {
                    return p
                }
            }
        }
        return nil
    }
}
