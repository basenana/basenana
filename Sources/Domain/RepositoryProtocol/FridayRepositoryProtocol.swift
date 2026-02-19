//
//  FridayRepositoryProtocol.swift
//  Domain
//
//  Protocol for Friday Repository
//

import Foundation

public protocol FridayRepositoryProtocol {
    func chat(message: String, sessionId: String, name: String?, contextEntries: [String]?, handler: @escaping (FridayChatEvent) async -> Void) async throws
    func sessions() async throws -> [FridaySession]
    func session(id: String) async throws -> (meta: FridaySession, messages: [FridaySessionMessage])
    func createSession(name: String) async throws -> FridaySession
    func deleteSession(id: String) async throws
}
