//
//  FileRepositoryProtocol.swift
//
//
//  Created by Hypo on 2024/9/15.
//

import Foundation
import Entities


public protocol FileRepositoryProtocol {
    func WriteFile(entry: Int64, off: Int64, len: Int64, input: Stream) throws
    func ReadFile(entry: Int64, off: Int64, len: Int64) throws -> Stream
}
