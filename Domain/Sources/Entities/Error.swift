//
//  Error.swift
//
//
//  Created by Hypo on 2024/9/15.
//

import Foundation


public enum RepositoryError: Error {
    case unimplement
    case invalidHost
    case invalidPort
    case invalidAccessKey
    case invalidResourceID
    case streamBroken
    case loginFailed(Error)
}
