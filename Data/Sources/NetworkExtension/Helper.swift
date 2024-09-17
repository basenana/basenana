//
//  Helper.swift
//  basenana
//
//  Created by Hypo on 2024/6/20.
//

import Foundation
import GRPC

let encodingConfiguration = ClientMessageEncoding.Configuration(
    forRequests: .gzip,
    decompressionLimit: .ratio(20)
)


let defaultCallOptions = CallOptions(timeLimit: .timeout(.seconds(10)), messageEncoding: .enabled(encodingConfiguration))

