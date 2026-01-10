//
//  ConfigClient.swift
//
//  REST API implementation of Config client
//

import Foundation
import Domain
import Data

public class ConfigClient: ConfigClientProtocol {

    private let apiClient: APIClient

    public init(apiClient: APIClient) {
        self.apiClient = apiClient
    }

    public func GetConfig(group: String, name: String) async throws -> APIConfigResponse {
        let response: ConfigResponse = try await apiClient.request(
            .config(group: group, name: name),
            responseType: ConfigResponse.self
        )

        return APIConfigResponse(
            group: response.group,
            name: response.name,
            value: response.value
        )
    }

    public func SetConfig(group: String, name: String, value: String) async throws -> APIConfigResponse {
        let request = SetConfigRequest(value: value)

        let response: ConfigResponse = try await apiClient.request(
            .configSet(group: group, name: name),
            body: request,
            responseType: ConfigResponse.self
        )

        return APIConfigResponse(
            group: response.group,
            name: response.name,
            value: response.value
        )
    }

    public func ListConfigs(group: String) async throws -> [APIConfigItem] {
        let response: ConfigsResponse = try await apiClient.request(
            .configsGroup(group: group),
            responseType: ConfigsResponse.self
        )

        return response.items.map { dto in
            APIConfigItem(
                group: dto.group,
                name: dto.name,
                value: dto.value,
                changedAt: dto.changed_at
            )
        }
    }

    public func DeleteConfig(group: String, name: String) async throws {
        _ = try await apiClient.request(
            .configDelete(group: group, name: name),
            responseType: DeleteConfigResponse.self
        )
    }
}
