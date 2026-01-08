//
//  RestAPIClient.swift
//  Data
//
//  REST API client wrapper replacing gRPC ClientSet
//

import Foundation
import NetworkCore

public class RestAPIClient {
    public let apiClient: APIClient
    public let host: String
    public let port: Int
    public let namespace: String

    public init(host: String, port: Int, username: String, password: String, namespace: String) {
        let baseURL = "http://\(host):\(port)"
        self.apiClient = APIClient(baseURL: baseURL, username: username, password: password)
        self.host = host
        self.port = port
        self.namespace = namespace
    }

    public convenience init(host: String, port: Int, accessTokenKey: String, secretToken: String, namespace: String) {
        // For backward compatibility, use accessTokenKey as username
        self.init(host: host, port: port, username: accessTokenKey, password: secretToken, namespace: namespace)
    }
}
