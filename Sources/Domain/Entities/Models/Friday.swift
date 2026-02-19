//
//  Friday.swift
//  Domain
//
//  Domain entities for Friday AI Chat
//

import Foundation

public struct FridayMessage: Sendable {
    public let reasoning: String?
    public let content: String?

    public init(reasoning: String?, content: String?) {
        self.reasoning = reasoning
        self.content = content
    }
}

public struct FridayEvent: Sendable {
    public let id: String?
    public let event: String?
    public let entryUri: String?
    public let time: Date?

    public init(id: String?, event: String?, entryUri: String?, time: Date?) {
        self.id = id
        self.event = event
        self.entryUri = entryUri
        self.time = time
    }
}

public struct FridayExtraValueDomain: Sendable {
    public let name: String?
    public let arguments: String?

    public init(name: String?, arguments: String?) {
        self.name = name
        self.arguments = arguments
    }
}

public enum FridayChatEvent: Sendable {
    case message(FridayMessage)
    case event(FridayEvent)
    case done

    public var isDone: Bool {
        if case .done = self {
            return true
        }
        return false
    }
}

public struct FridaySession: Identifiable, Sendable {
    public let id: String
    public let name: String
    public let createdAt: Date
    public let updatedAt: Date

    public init(id: String, name: String, createdAt: Date, updatedAt: Date) {
        self.id = id
        self.name = name
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

public struct FridaySessionMessage: Sendable {
    public let type: String
    public let content: String
    public let reasoning: String?
    public let toolName: String?
    public let time: Date

    public init(type: String, content: String, reasoning: String?, toolName: String?, time: Date) {
        self.type = type
        self.content = content
        self.reasoning = reasoning
        self.toolName = toolName
        self.time = time
    }
}
