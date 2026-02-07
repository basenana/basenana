//
//  FetchWebPageUseCaseProtocol.swift
//  Domain
//
//  Protocol for fetching and processing web pages.
//

import Foundation

public protocol FetchWebPageUseCaseProtocol {
    func execute(url: String, title: String?) async throws -> EntryInfo
}
