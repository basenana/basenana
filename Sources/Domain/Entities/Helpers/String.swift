//
//  String.swift
//  Domain
//
//  Created by Hypo on 2024/11/24.
//

import Foundation

private let illegalFileNameChars = CharacterSet(charactersIn: "\\/:*?\"<>|")

public func sanitizeFileName(_ name: String) -> String {
    var result = name.trimmingCharacters(in: .whitespacesAndNewlines)

    let illegalChars = illegalFileNameChars
    result = result
        .components(separatedBy: illegalChars)
        .joined(separator: " ")
        .replacingOccurrences(of: " ", with: "_")
        .replacingOccurrences(of: ".", with: "_")

    if result.isEmpty {
        return "_"
    }

    let maxLength = 100
    if result.count > maxLength {
        return String(result.prefix(maxLength))
    }

    return result
}

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
