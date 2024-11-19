//
//  DocumentReadViewModel.swift
//  Document
//
//  Created by Hypo on 2024/11/18.
//
import SwiftUI
import Foundation
import Entities
import UseCase
import AppState


@available(macOS 14.0, *)
@Observable
@MainActor
public class DocumentReadViewModel {
    var docID: Int64
    var store: StateStore
    var usercase: DocumentUseCase
    
    var document: DocumentDetail? = nil
    
    init(docID:Int64, store: StateStore, usercase: DocumentUseCase) {
        self.docID = docID
        self.store = store
        self.usercase = usercase
    }
    
    func loadDocument() {
        let detail = try! usercase.getDocumentDetails(document: docID)
        document = detail
    }
    
}
