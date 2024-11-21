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


@available(macOS 14.0, *)
@Observable
@MainActor
public class DocumentReadViewModel {
    var docID: Int64
    var store: StateStore
    var usecase: DocumentUseCaseProtocol
    
    var document: DocumentDetail? = nil
    
    public init(docID:Int64, store: StateStore, usecase: DocumentUseCaseProtocol) {
        self.docID = docID
        self.store = store
        self.usecase = usecase
    }
    
    func loadDocument() {
        do {
            let detail = try usecase.getDocumentDetails(document: docID)
            document = detail
        } catch {
            store.alert.display(msg: "load document failed: \(error)")
        }
    }
    
}
