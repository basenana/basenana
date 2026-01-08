//
//  String.swift
//  Domain
//
//  Created by Hypo on 2024/11/24.
//


public func randomString(randomOfLength length: Int) -> String {
    guard length > 0 else { return "" }
    let base = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    var randomString = ""
    for _ in 1...length {
        guard let randomCharacter = base.randomElement() else { continue }
        randomString.append(randomCharacter)
    }
    return randomString
}
