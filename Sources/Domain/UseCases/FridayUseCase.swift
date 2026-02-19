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

    public func chat(message: String, sessionId: String, name: String?, contextEntries: [String]?, handler: @escaping (FridayChatEvent) async -> Void) async throws {
        try await repository.chat(message: message, sessionId: sessionId, name: name, contextEntries: contextEntries, handler: handler)
    }

    public func getSessions() async throws -> [FridaySession] {
        try await repository.sessions()
    }

    public func getSession(id: String) async throws -> (meta: FridaySession, messages: [FridaySessionMessage]) {
        try await repository.session(id: id)
    }

    public func createSession(name: String) async throws -> FridaySession {
        try await repository.createSession(name: name)
    }

    public func deleteSession(id: String) async throws {
        try await repository.deleteSession(id: id)
    }
}
