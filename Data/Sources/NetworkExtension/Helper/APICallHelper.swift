//
//  APICallHelper.swift
//  Data
//
//  Created by Hypo on 2024/6/20.
//

import Foundation
import NetworkCore
import GRPC

let encodingConfiguration = ClientMessageEncoding.Configuration(
    forRequests: .gzip,
    decompressionLimit: .ratio(20)
)


let defaultCallOptions = CallOptions(timeLimit: .timeout(.seconds(10)), messageEncoding: .enabled(encodingConfiguration))


func paresGroupTreeChild(group: Api_V1_GetGroupTreeResponse.GroupEntry) -> APIGroup{
    var gvm = group.entry.toGroup()!
    if !group.children.isEmpty{
        gvm.children = []
        for grp in group.children {
            gvm.children!.append(paresGroupTreeChild(group: grp))
        }
    }
    return gvm
}
