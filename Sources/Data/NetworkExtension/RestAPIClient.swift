//
//  RestAPIClient.swift
//  Data
//
//  REST API client wrapper replacing gRPC ClientSet
//

import Foundation
import Data

public class RestAPIClient {
    public let apiClient: APIClient
    public let apiURL: String
    public let namespace: String

    public init(apiURL: String, token: String, namespace: String) {
        self.apiClient = APIClient(baseURL: apiURL, token: token, namespace: namespace)
        self.apiURL = apiURL
        self.namespace = namespace
    }
}
