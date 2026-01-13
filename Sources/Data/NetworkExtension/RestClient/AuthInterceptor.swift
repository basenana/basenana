//
//  AuthInterceptor.swift
//  Data
//
//  Bearer Token authentication interceptor
//

import Foundation

struct AuthInterceptor {
    let token: String

    init(token: String) {
        self.token = token
    }

    var authorizationHeader: String {
        return "Bearer \(token)"
    }

    func configureRequest(_ request: inout URLRequest) {
        request.setValue(authorizationHeader, forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
    }
}
