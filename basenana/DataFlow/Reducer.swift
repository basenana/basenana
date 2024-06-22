//
//  Reducer.swift
//  basenana
//
//  Created by Hypo on 2024/6/19.
//

import Foundation


extension Store {
    func reducer(state: inout AppState, action: AppAction, environment: AppEnvironment) -> Task<AppAction?, Error>? {
        
        switch action {
        case .login:
            return Task {
                let clientset = try environment.clientFactory.makeClient()
                let info = try clientset.fsInfo()
                return .setFsInfo(fsInfo: info)
            }
            
        case .setFsInfo(fsInfo: let fsInfo):
            state.fsInfo = fsInfo
            
            return Task {
                let rootID = fsInfo.rootID
                let root = RootGroupModel()
                let clientSet = try clientFactory.makeClient()
                log.debug("start init group tree, id: \(rootID)")
                
                let req = Api_V1_GetGroupTreeRequest()
                let call = clientSet.entries.groupTree(req, callOptions: defaultCallOptions)
                do {
                    let response = try await call.response.get()
                    root.children = []
                    for grp in response.root.children {
                        root.children?.append(paresGroupTreeChild(group: grp))
                    }
                } catch {
                    log.error("[groupService] find children failed \(error)")
                    throw error
                }
                
                log.debug("init group tree finish, id: \(rootID)")
                return .initGroupTree(root: root)
            }
            
        case .initGroupTree(root: let root):
            state.groupTree = root
            return nil
            
        case .quickInbox(urlStr: let urlStr, filename: let filename, fileType: let fileType, data: let data):
            let inboxID = state.fsInfo.inboxID
            return Task {
                let clientSet = try clientFactory.makeClient()
                log.debug("inbox to \(filename) url: \(urlStr)")
                
                var request = Api_V1_QuickInboxRequest()
                request.url = urlStr
                request.filename = filename
                switch fileType {
                case "webarchive":
                    request.fileType = .webArchiveFile
                case "html":
                    request.fileType = .htmlFile
                case "bookmark":
                    request.fileType = .bookmarkFile
                default:
                    request.fileType = .webArchiveFile
                }
                request.clutterFree = true
                
                if data != nil {
                    request.data = data!
                }else {
                    log.warning("quick inbox without data content")
                }
                let call = clientSet.inbox.quickInbox(request, callOptions: defaultCallOptions)
                do {
                    let response = try await call.response.get()
                    log.debug("new entey inboxed \(response.entryID)")
                } catch {
                    log.error("new entey inbox failed \(error)")
                    throw error
                }
                
                var newInboxEntries: [EntryInfoModel] = []
                do {
                    var listInboxReq = Api_V1_ListGroupChildrenRequest()
                    listInboxReq.parentID = inboxID
                    let listCall = clientSet.entries.listGroupChildren(listInboxReq, callOptions: defaultCallOptions)
                    
                    let listResp = try await listCall.response.get()
                    for en in listResp.entries{
                        newInboxEntries.append(en.toEntry())
                    }
                }
                
                return .updateInbox(enties: newInboxEntries)
            }
            
        case .updateInbox(enties: let entries):
            state.inbox = entries
            return nil
            
        case .createGroup(groupName: let groupName, parentId: let parentId):
            return Task {
                let clientSet = try clientFactory.makeClient()
                
                var request = Api_V1_CreateEntryRequest()
                request.kind = "group"
                request.name = groupName
                request.parentID = parentId
                
                var grp: GroupModel?
                let call = clientSet.entries.createEntry(request, callOptions: defaultCallOptions)
                do {
                    let resp = try await call.response.get()
                    grp = resp.entry.toGroup()
                } catch {
                    log.error("create group failed \(error)")
                    throw error
                }
                
                guard let _ = grp else {
                    return nil
                }
                
                return .addGroupToGroupTree(children: [grp!])
            }
            
        case .updateEntry(en: let en):
            return Task {
                let clientSet = try clientFactory.makeClient()
                var request = Api_V1_UpdateEntryRequest()
                request.entry = Api_V1_EntryDetail.fromEntryDetail(en: en)
                
                do {
                    let call = clientSet.entries.updateEntry(request, callOptions: defaultCallOptions)
                    let _ = try await call.response.get()
                } catch {
                    log.error("update entry \(en.id) failed \(error)")
                    throw error
                }
                return nil
            }
            
        case .deleteEntries(entryIds: let entryIds):
            return Task {
                let clientSet = try clientFactory.makeClient()
                var needUpdateGroup: [GroupModel] = []
                for entryId in entryIds {
                    var request = Api_V1_DeleteEntryRequest()
                    request.entryID = entryId
                    
                    let call = clientSet.entries.deleteEntry(request, callOptions: defaultCallOptions)
                    do {
                        let resp = try await call.response.get()
                        if resp.entry.isGroup{
                            let grp = GroupModel(parentID: resp.entry.parent.id, groupID: resp.entry.id, groupName: resp.entry.name)
                            grp.parentID = resp.entry.parent.id
                            needUpdateGroup.append(grp)
                        }
                    } catch {
                        log.error("delete entry failed \(error)")
                        throw error
                    }
                }
                return .removeGroupFromGroupTree(children: needUpdateGroup)
            }
            
        case .moveEntriesToGroup(entries: let entries, groupID: let groupID):
            for entryId in entries {
                state.groupTree.changeParent(groupID: entryId, newParentID: groupID)
            }
            
            return Task {
                let clientSet = try clientFactory.makeClient()
                for entryId in entries {
                    log.info("move \(entryId) -> \(groupID)")
                    var request = Api_V1_ChangeParentRequest()
                    request.entryID = entryId
                    request.newParentID = groupID
                    let call = clientSet.entries.changeParent(request, callOptions: defaultCallOptions)
                    
                    do {
                        let _ = try await call.response.get()
                    } catch {
                        log.error("move entry \(entryId) failed \(error)")
                        throw error
                    }
                }
                return nil
            }
            
        case .addGroupToGroupTree(children: let children):
            for child in children {
                state.groupTree.addChildGroup(parentID: child.parentID, childID: child.groupID, childName: child.groupName)
            }
            return nil

        case .removeGroupFromGroupTree(children: let children):
            for child in children {
                state.groupTree.removeChildGroup(parentID: child.parentID, childID: child.groupID)
            }
            return nil

        case .updateDocument(docUpdate: let docUpdate):
            return Task {
                let clientSet = try clientFactory.makeClient()
                var request = Api_V1_UpdateDocumentRequest()
                request.document.id = docUpdate.docId
                if let unread = docUpdate.unread {
                    request.setMark = unread ? Api_V1_UpdateDocumentRequest.DocumentMark.unread:Api_V1_UpdateDocumentRequest.DocumentMark.read
                }
                if let mark = docUpdate.marked {
                    request.setMark = mark ? Api_V1_UpdateDocumentRequest.DocumentMark.marked:Api_V1_UpdateDocumentRequest.DocumentMark.unmarked
                }
                
                do {
                    let call = clientSet.document.updateDocument(request, callOptions: defaultCallOptions)
                    let _ = try await call.response.get()
                } catch {
                    log.error("update docuemnt failed \(error)")
                    throw error
                }
                return nil
            }
            
        case .ingestDocument(entryId: let entryId):
            return Task {
                let clientSet = try clientFactory.makeClient()
                var requset = Api_V1_TriggerWorkflowRequest()
                requset.workflowID = "buildin.ingest"
                requset.target.entryID = entryId
                let call = clientSet.workflow.triggerWorkflow(requset, callOptions: defaultCallOptions)
                do {
                    let _ = try await call.response.get()
                } catch {
                    log.error("trigger ingest workflow failed \(error)")
                    throw error
                }
                return nil
            }
            
        case .alert(msg: let msg):
            state.alert.alertMessage = msg
            state.alert.needAlert = true
            return nil
            
        case .offAlert:
            state.alert.alertMessage = ""
            state.alert.needAlert = false
            return nil
            
        case .gotoDestination(to: let to):
            state.destinations.append(to)
            return nil

        case .setDestination(to: let to):
            if state.destinations == to {
                return nil
            }
            if state.destinations.isEmpty {
                state.destinations = to
                return nil
            }
            state.destinations.removeAll()
            return Task {
                try await Task.sleep(nanoseconds: 1000)
                return .updateDestination(to: to)
            }
        case .updateDestination(to: let to):
            state.destinations = to
            return nil
            
        case .updateSidebarSelection(select: let select):
            if let nextSelect = select {
                state.sidebarSelection = nextSelect
            }
            return nil
            
        }
    }
}
