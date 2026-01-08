//
//  AuthInterceptor.swift
//  Data
//
//  Basic Auth authentication interceptor
//

import Foundation

struct AuthInterceptor {
    let username: String
    let password: String

    init(username: String, password: String) {
        self.username = username
        self.password = password
    }

    var authorizationHeader: String {
        let credentials = "\(username):\(password)"
        guard let credentialsData = credentials.data(using: .utf8) else {
            return ""
        }
        let base64Credentials = credentialsData.base64EncodedString()
        return "Basic \(base64Credentials)"
    }

    func configureRequest(_ request: inout URLRequest) {
        request.setValue(authorizationHeader, forHTTPHeaderField: "Authorization")
        request.setValue("hypo", forHTTPHeaderField: "X-Namespace")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
    }
}
