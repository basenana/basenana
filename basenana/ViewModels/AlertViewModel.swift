//
//  AlertViewModel.swift
//  basenana
//
//  Created by Hypo on 2024/6/16.
//

import Foundation


@Observable
class AlertStore {
    var titleInfo: String = ""
    var alertMessage: String = ""
    var needAlert: Bool = false
    
    func trigger(title: String, message: String){
        if message == ""{
            return
        }
        
        titleInfo = title
        alertMessage = message
        needAlert = true
    }

    func trigger(message: String){
        if message == ""{
            return
        }
        
        titleInfo = "Error"
        alertMessage = message
        needAlert = true
    }
    
    func reset(){
        alertMessage = ""
        needAlert = false
    }
}
