//
//  Error.swift
//
//
//  Created by Hypo on 2024/9/15.
//

import Foundation


public enum BizError: Error {
    case notGroup
    case invalidArg(String)
}


public enum RepositoryError: Error {
    case unimplement
    case invalidHost
    case invalidPort
    case invalidAccessKey
    case invalidResourceID
    case notFound
    case streamBroken
    case loginFailed(Error)
    case canceled
}


public enum UseCaseError: Error {
    case canceled
    case unimplement
}
