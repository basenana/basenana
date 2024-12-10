//
//  ToAPIModel.swift
//
//
//  Created by Hypo on 2024/9/17.
//

import Foundation
import NetworkCore


extension Api_V1_EntryInfo {
    func toEntry() -> APIEntryInfo {
        return APIEntryInfo(id: self.id, name: self.name, kind: self.kind, isGroup: self.isGroup, size: self.size, parentID: self.parentID, createdAt: self.createdAt.date, changedAt: self.changedAt.date, modifiedAt: self.modifiedAt.date, accessAt: self.accessAt.date
        )
    }
    
    func toGroup() -> APIGroup? {
        if self.isGroup {
            return APIGroup(id: self.id, groupName: self.name, parentID: self.parentID)
        }
        return nil
    }
}


extension Api_V1_EntryDetail {
    func toEntry(properties: [Api_V1_Property]) -> APIEntryDetail {
        var enProperties: [APIEntryProperty]=[]
        for property in properties {
            enProperties.append(APIEntryProperty(key: property.key, value: property.value, encoded: property.encoded))
        }
        return APIEntryDetail(
            id: self.id, name: self.name, aliases: self.aliases, parent: self.parent.id,
            kind: self.kind, isGroup: self.isGroup, size: self.size, version: self.version,
            namespace: self.namespace, storage: self.storage,
            uid: self.access.uid, gid: self.access.gid, permissions: self.access.permissions,
            createdAt: self.changedAt.date, changedAt: self.changedAt.date, modifiedAt: self.modifiedAt.date, accessAt: self.accessAt.date,
            properties: enProperties
        )
    }
    
    static func fromEntryDetail(en: APIEntryDetail) -> Api_V1_EntryDetail {
        var entry = Api_V1_EntryDetail()
        entry.id = en.id
        // update name only
        entry.name = en.name != "" ? en.name : ""
        return entry
    }
}

extension Api_V1_Property {
    func toEntryProperty() -> APIEntryProperty {
        return APIEntryProperty(key: self.key, value: self.value, encoded: self.encoded)
    }
}


extension Api_V1_DocumentInfo {
    func toDocuement() -> APIDocumentInfo{
        var enProperties: [APIEntryProperty]=[]
        for property in self.properties {
            enProperties.append(APIEntryProperty(key: property.key, value: property.value, encoded: property.encoded))
        }
        return APIDocumentInfo(
            id: self.id, oid: self.entryID, parentId: self.parentEntryID, name: self.name, namespace: self.namespace, source: self.source,
            marked: self.marked, unread: self.unread, subContent: self.subContent, headerImage: self.headerImage,
            createdAt: self.createdAt.date, changedAt: self.changedAt.date, properties: enProperties, parent: self.parent.toEntry())
    }
}


extension Api_V1_DocumentDescribe {
    func toDocuement() -> APIDocumentDetail{
        return APIDocumentDetail(
            id: self.id, oid: self.entryID, parentId: self.parentEntryID, name: self.name, namespace: self.namespace, source: self.source,
            marked: self.marked, unread: self.unread, keyWords: self.keyWords, content: self.htmlContent, summary: self.summary,
            createdAt: self.createdAt.date, changedAt: self.changedAt.date)
    }
}


extension Api_V1_RoomInfo {
    func toRoom() -> APIRoom {
        let messages = self.messages
        var ms: [APIRoomMessage] = []
        for message in messages {
            ms.append(APIRoomMessage(
                id: message.id,
                namespace: message.namespace,
                roomid: message.id,
                sender: message.sender,
                message: message.message,
                sendAt: message.sendAt.date,
                createdAt: message.createdAt.date
            ))
        }
        return APIRoom(
            id: self.id, namespace: self.namespace, oid: self.entryID,
            title: self.title, prompt: self.prompt,
            createdAt: self.createdAt.date, messages: ms
        )
    }
}

extension Api_V1_WorkflowInfo {
    func toWorkflow() -> APIWorkflow {
        return APIWorkflow(id: self.id, name: self.name, executor: self.executor, queueName: self.queueName, healthScore: Int(self.healthScore), createdAt: self.createdAt.date, updatedAt: self.updatedAt.date, lastTriggeredAt: self.lastTriggeredAt.date)
    }
}


extension Api_V1_WorkflowJobDetail {
    func toJob() -> APIWorkflowJob {
        let target = APIWorkflowJobTarget(entryID: self.target.entryID, parentEntryID: self.target.parentEntryID)
        var steps = [APIWorkflowJobStep]()
        for step in self.steps {
            steps.append(APIWorkflowJobStep(name: step.name, status: step.status, message: step.message))
        }
        return APIWorkflowJob(id: self.id, workflow: self.workflow, triggerReason: self.triggerReason, status: self.status, message: self.message, executor: self.executor, queueName: self.executor, jobTarget: target, steps: steps, createdAt: self.createdAt.date, updatedAt: self.updatedAt.date, startAt: self.startAt.date, finishAt: self.finishAt.date)
    }
}
