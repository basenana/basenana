//
//  ConfigClientProtocol.swift
//
//  Protocol for Config API client
//

import Foundation

public struct APIConfigItem {
    public let group: String
    public let name: String
    public let value: String
    public let changedAt: Date?

    public init(group: String, name: String, value: String, changedAt: Date?) {
        self.group = group
        self.name = name
        self.value = value
        self.changedAt = changedAt
    }
}

public struct APIConfigResponse {
    public let group: String
    public let name: String
    public let value: String

    public init(group: String, name: String, value: String) {
        self.group = group
        self.name = name
        self.value = value
    }
}

public protocol ConfigClientProtocol {
    func GetConfig(group: String, name: String) async throws -> APIConfigResponse
    func SetConfig(group: String, name: String, value: String) async throws -> APIConfigResponse
    func ListConfigs(group: String) async throws -> [APIConfigItem]
    func DeleteConfig(group: String, name: String) async throws
}
