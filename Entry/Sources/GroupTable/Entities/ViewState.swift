//
//  ViewState.swift
//  Entry
//
//  Created by Hypo on 2024/11/22.
//

import SwiftUI
import Entities


@Observable
class TreeListState {
    static var shared = TreeListState()
    
    var root: Entities.Group = UnknownGroup.shared
    
    // current opened group
    var opendGroup: Entities.Group? = nil
    
    // create group
    var showCreateGroup: Bool = false
    var createGroupInParent: Int64 = 0
    var createGroupType: GroupType = .standard
    
    // quick inbox
    var showQuickInbox: Bool = false

    init(){ }
}
