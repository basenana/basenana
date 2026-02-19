//
//  FridayUseCaseProtocol.swift
//  Domain
//
//  Protocol for Friday UseCase
//

import Foundation

public protocol FridayUseCaseProtocol {
    func chat(message: String, sessionId: String, name: String?, contextEntries: [String]?, handler: @escaping (FridayChatEvent) async -> Void) async throws
    func getSessions() async throws -> [FridaySession]
    func getSession(id: String) async throws -> (meta: FridaySession, messages: [FridaySessionMessage])
    func createSession(name: String) async throws -> FridaySession
    func deleteSession(id: String) async throws
}
