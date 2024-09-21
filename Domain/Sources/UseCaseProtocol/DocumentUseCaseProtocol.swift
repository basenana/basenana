//
//  DocumentUseCaseProtocol.swift
//
//
//  Created by Hypo on 2024/9/13.
//

import Foundation
import Entities


public protocol DocumentUseCaseProtocol {
    func getDocumentDetails(entry: Int64) throws -> DocumentDetail
    func getDocumentDetails(document: Int64) throws -> DocumentDetail
    func setDocumentMarkState(ismark: Bool) throws
    func setDocumentReadState(unread: Bool) throws
}
