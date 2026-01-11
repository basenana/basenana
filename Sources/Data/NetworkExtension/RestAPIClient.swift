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
    public let host: String
    public let port: Int
    public let namespace: String

    public init(host: String, port: Int, token: String, namespace: String) {
        let baseURL = "http://\(host):\(port)"
        self.apiClient = APIClient(baseURL: baseURL, token: token, namespace: namespace)
        self.host = host
        self.port = port
        self.namespace = namespace
    }
}
