//
//  Environment.swift
//  basenana
//
//  Created by Hypo on 2024/11/20.
//

import Foundation
import Data


class Environment {
    static var shared = Environment()

    var restAPIClient: RestAPIClient? = nil

    private init(){}
}
