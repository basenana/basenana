//
//  Friday.swift
//  Data
//
//  API models for Friday SSE Chat
//

import Foundation

// MARK: - Request Models

public struct FridayChatRequest: Encodable {
    public let message: String
    public let sessionId: String
    public let name: String?
    public let contextEntries: [String]?

    public init(message: String, sessionId: String, name: String?, contextEntries: [String]?) {
        self.message = message
        self.sessionId = sessionId
        self.name = name
        self.contextEntries = contextEntries
    }

    enum CodingKeys: String, CodingKey {
        case message
        case sessionId = "session_id"
        case name
        case contextEntries = "context_entries"
    }
}

// MARK: - SSE Event Data Models

public struct FridayMessageAppend: Decodable {
    public let reasoning: String?
    public let content: String?

    public init(reasoning: String?, content: String?) {
        self.reasoning = reasoning
        self.content = content
    }
}

public struct FridayEventUpdate: Decodable {
    public let id: String?
    public let event: String?
    public let entryUri: String?
    public let time: String?

    public init(id: String?, event: String?, entryUri: String?, time: String?) {
        self.id = id
        self.event = event
        self.entryUri = entryUri
        self.time = time
    }

    enum CodingKeys: String, CodingKey {
        case id
        case event
        case entryUri = "entry_uri"
        case time
    }
}

public struct FridayExtraValue: Decodable {
    public let name: String?
    public let arguments: String?

    public init(name: String?, arguments: String?) {
        self.name = name
        self.arguments = arguments
    }
}

// MARK: - Stream Event Types

public enum FridayStreamEvent {
    case messageAppend(FridayMessageAppend)
    case eventUpdate(FridayEventUpdate)
    case done

    public var isDone: Bool {
        if case .done = self {
            return true
        }
        return false
    }
}

// MARK: - Session Models

public struct FridaySessionDTO: Decodable {
    public let id: String
    public let name: String
    public let createdAt: String
    public let updatedAt: String?

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        createdAt = try container.decode(String.self, forKey: .createdAt)
        updatedAt = try container.decodeIfPresent(String.self, forKey: .updatedAt)
    }

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

public struct FridaySessionsResponse: Decodable {
    public let sessions: [FridaySessionDTO]

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        sessions = try container.decode([FridaySessionDTO].self, forKey: .sessions)
    }

    enum CodingKeys: String, CodingKey {
        case sessions
    }
}

public struct FridaySessionMessageDTO: Decodable {
    public let type: String
    public let content: String
    public let reasoning: String?
    public let toolName: String?
    public let time: String

    enum CodingKeys: String, CodingKey {
        case type
        case content
        case reasoning
        case toolName = "tool_name"
        case time
    }
}

public struct FridaySessionDetailDTO: Decodable {
    public let meta: FridaySessionDTO
    public let messages: [FridaySessionMessageDTO]

    enum CodingKeys: String, CodingKey {
        case meta
        case messages
    }
}

public struct FridayCreateSessionRequest: Encodable {
    public let name: String

    public init(name: String) {
        self.name = name
    }
}
