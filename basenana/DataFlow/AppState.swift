//
//  AppState.swift
//  basenana
//
//  Created by Hypo on 2024/6/19.
//

import Foundation

struct AppState {
    var destinations = [Destination]()
    var sidebarSelection: Destination? = nil
    var alert = AlertModel()
    var fsInfo = FsInfoModel()
    var groupTree = RootGroupModel()
    var inbox = [EntryInfoModel]()
    
    var search = SearchModel()
    var currentGroup = GroupViewModel()
    
    var notifications = [NotificationModel]()
    var backgroundJob = [JobModel]()

}
