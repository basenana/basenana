//
//  Service.swift
//  basenana
//
//  Created by Hypo on 2024/6/15.
//

import Foundation

let service = Service()

class Service {
    var namespace: String = ""
    var rootID: Int64 = 0
}


enum ServiceError: Error {
    case ServerLost
}
