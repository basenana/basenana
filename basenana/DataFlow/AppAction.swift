//
//  AppAction.swift
//  basenana
//
//  Created by Hypo on 2024/6/19.
//

import Foundation


enum AppAction {

    case login
    
    case setFsInfo(fsInfo: FsInfoModel)

    case initGroupTree(root: RootGroupModel)

    case quickInbox(urlStr: String, filename: String, fileType: String, data: Data?)
    
    case updateInbox(enties: [EntryInfoModel])
    
    case search(query: String)

    case setOpenedGroupViewModel(group: GroupViewModel)

    case createGroup(groupName: String, parentId: Int64, opt: GroupCreateOptionModel)
    
    case updateEntry(en: EntryDetailModel)

    case deleteEntries(entryIds: [Int64])
    
    case moveEntriesToGroup(entries: [Int64], groupID: Int64)
    
    case changeGroupTree(entries: [Int64], groupID: Int64)

    case addGroupToGroupTree(children: [GroupModel])
    
    case removeGroupFromGroupTree(children: [GroupModel])
    
    case updateDocument(docUpdate: DocumentUpdate)
    
    case ingestDocument(entryId: Int64)
    
    case alert(msg: String?)
    
    case showSheet(sheetKind: SheetKind?)

    case setDestination(to: [Destination])

    case updateDestination(to: [Destination])

    case gotoDestination(Destination)
    
    case updateSidebarSelection(select: Destination)
}
