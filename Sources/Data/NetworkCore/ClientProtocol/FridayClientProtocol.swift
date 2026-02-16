//
//  FridayClientProtocol.swift
//  Data
//
//  Protocol for Friday SSE Chat client
//

import Foundation
import Domain

public protocol FridayClientProtocol {
    func chat(message: String, handler: @escaping (FridayStreamEvent) async -> Void) async throws
}
