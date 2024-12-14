//
//  Environment.swift
//  basenana
//
//  Created by Hypo on 2024/11/20.
//

import Foundation
import NetworkExtension


class Environment {
    static var shared = Environment()
    
    var clientSet: ClientSet? = nil
    
    private init(){}
}
