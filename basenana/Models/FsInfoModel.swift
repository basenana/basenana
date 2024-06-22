//
//  FsInfoModel.swift
//  basenana
//
//  Created by Hypo on 2024/6/19.
//

import Foundation


class FsInfoModel {
    var fsApiReady = false
    var namespace = ""
    var rootID: Int64 = 0
    var inboxID: Int64 = 0
    
    func rootGroupModel() -> GroupModel {
        return GroupModel(parentID: rootID, groupID: rootID, groupName: "root")
    }

    func inboxGroupModel() -> GroupModel {
        return GroupModel(parentID: rootID, groupID: inboxID, groupName: "Inbox")
    }
}
