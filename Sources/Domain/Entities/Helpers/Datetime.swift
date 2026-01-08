//
//  Datetime.swift
//  Domain
//
//  Created by Hypo on 2024/11/18.
//

import Foundation


public func RFC3339Formatter() -> DateFormatter {
    let formatter = DateFormatter()
    formatter.locale = Locale(identifier: "en_US_POSIX")
    formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
    return formatter
}

