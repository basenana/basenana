//
//  FridayRepositoryProtocol.swift
//  Domain
//
//  Protocol for Friday Repository
//

import Foundation

public protocol FridayRepositoryProtocol {
    func chat(message: String, handler: @escaping (FridayChatEvent) async -> Void) async throws
}
