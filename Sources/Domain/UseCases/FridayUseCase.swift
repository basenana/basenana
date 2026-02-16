//
//  FridayUseCase.swift
//  Domain
//
//  UseCase implementation for Friday AI Chat
//

import Foundation

public class FridayUseCase: FridayUseCaseProtocol {

    private let repository: FridayRepositoryProtocol

    public init(repository: FridayRepositoryProtocol) {
        self.repository = repository
    }

    public func chat(message: String, handler: @escaping (FridayChatEvent) async -> Void) async throws {
        try await repository.chat(message: message, handler: handler)
    }
}
