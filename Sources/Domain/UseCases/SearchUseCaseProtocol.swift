//
//  SearchUseCaseProtocol.swift
//  Domain
//
//  Created by Hypo on 2024/9/18.
//

import Foundation



public protocol SearchUseCaseProtocol {
    func Search(query: String, page: Int?, pageSize: Int?) async throws -> [SearchResult]
}
