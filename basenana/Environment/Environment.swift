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
    
    private init(){
        NotificationCenter.default.addObserver(
            forName: NSNotification.Name("login"),
            object: nil, queue: .main, using: { notification in
                if let cs = notification.object as? ClientSet? {
                    self.clientSet = cs
                }
            })
    }
}
