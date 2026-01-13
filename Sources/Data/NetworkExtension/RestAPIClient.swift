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

    public init(apiURL: String, token: String) {
        self.apiClient = APIClient(baseURL: apiURL, token: token)
        self.apiURL = apiURL
    }
}
