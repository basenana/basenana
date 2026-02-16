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
    public let id: String
    public let type: String
    public let source: String
    public let data: String
    public let extraValue: FridayExtraValueDomain?
    public let time: Date?

    public init(id: String, type: String, source: String, data: String, extraValue: FridayExtraValueDomain?, time: Date?) {
        self.id = id
        self.type = type
        self.source = source
        self.data = data
        self.extraValue = extraValue
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
