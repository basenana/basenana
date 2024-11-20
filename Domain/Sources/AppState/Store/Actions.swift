//
//  Actions.swift
//  Domain
//
//  Created by Hypo on 2024/9/21.
//


public enum AppAction {
    
    case setFsInfo(fsInfo: FSInfo)

    case alert(msg: String?)
    
    case setDestination(to: [Destination])

    case updateDestination(to: [Destination])

    case gotoDestination(Destination)
    
    case updateSidebarSelection(select: Destination)
}
