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

    public init(message: String) {
        self.message = message
    }
}

// MARK: - SSE Event Data Models

public struct FridayMessageAppend: Decodable {
    public let reasoning: String?
    public let content: String

    public init(reasoning: String?, content: String) {
        self.reasoning = reasoning
        self.content = content
    }
}

public struct FridayEventUpdate: Decodable {
    public let id: String
    public let type: String
    public let source: String
    public let specversion: String
    public let datacontenttype: String
    public let data: String
    public let extraValue: FridayExtraValue?
    public let time: String

    public init(id: String, type: String, source: String, specversion: String, datacontenttype: String, data: String, extraValue: FridayExtraValue?, time: String) {
        self.id = id
        self.type = type
        self.source = source
        self.specversion = specversion
        self.datacontenttype = datacontenttype
        self.data = data
        self.extraValue = extraValue
        self.time = time
    }

    enum CodingKeys: String, CodingKey {
        case id
        case type
        case source
        case specversion
        case datacontenttype
        case data
        case extraValue = "extra_value"
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
