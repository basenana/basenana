//
//  FridayClientProtocol.swift
//  Data
//
//  Protocol for Friday SSE Chat client
//

import Foundation
import Domain

public protocol FridayClientProtocol {
    func chat(message: String, sessionId: String, name: String?, contextEntries: [String]?, handler: @escaping (FridayStreamEvent) async -> Void) async throws
    func getSessions() async throws -> [FridaySessionDTO]
    func getSession(id: String) async throws -> FridaySessionDetailDTO
    func createSession(name: String) async throws -> FridaySessionDTO
    func deleteSession(id: String) async throws
}
