//
//  PaperFlowUseCaseProtocol.swift
//  Domain
//
//  Created by Hypo on 2024/9/18.
//

import Foundation



public protocol PaperFlowUseCaseProtocol {
    func listUnreadDocuments(page: Pagination) throws -> [DocumentInfo]
    func listMarkedDocuments(page: Pagination) throws -> [DocumentInfo]
}
