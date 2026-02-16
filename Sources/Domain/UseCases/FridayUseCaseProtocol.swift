//
//  FridayUseCaseProtocol.swift
//  Domain
//
//  Protocol for Friday UseCase
//

import Foundation

public protocol FridayUseCaseProtocol {
    func chat(message: String, handler: @escaping (FridayChatEvent) async -> Void) async throws
}
