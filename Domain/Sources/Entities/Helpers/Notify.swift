//
//  Notify.swift
//  Domain
//
//  Created by Hypo on 2024/12/6.
//
import Foundation


public func sentAlert(_ msg: String){
    NotificationCenter.default.post(name: NSNotification.Name("alert"), object: msg)
}
