//
//  AuthInterceptor.swift
//  Data
//
//  Bearer Token authentication interceptor
//

import Foundation

struct AuthInterceptor {
    let token: String
    let namespace: String

    init(token: String, namespace: String) {
        self.token = token
        self.namespace = namespace
    }

    var authorizationHeader: String {
        return "Bearer \(token)"
    }

    func configureRequest(_ request: inout URLRequest) {
        request.setValue(authorizationHeader, forHTTPHeaderField: "Authorization")
        request.setValue(namespace, forHTTPHeaderField: "X-Namespace")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
    }
}
