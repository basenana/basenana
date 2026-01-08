//
//  Notify.swift
//  Domain
//
//  Created by Hypo on 2024/12/12.
//

import SwiftUI

public extension Notification.Name {
    static let setDestination = Notification.Name(rawValue: "setDestination")
    static let updateDestination = Notification.Name(rawValue: "updateDestination")
    static let gotoDestination = Notification.Name(rawValue: "gotoDestination")
}



public func gotoDestination(_ dest: Destination){
    NotificationCenter.default.post(name: .gotoDestination, object: dest)
}

public func resetDestination(_ dest: Destination){
    NotificationCenter.default.post(name: .setDestination, object: [dest])
}
